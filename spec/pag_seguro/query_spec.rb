# encoding: utf-8

require 'spec_helper'

describe PagSeguro::Query do
  let(:transactions_xml){ File.open( File.expand_path( File.dirname(__FILE__) + '/../fixtures/transaction_history.xml') ) }

  describe "instance" do
    before { allow_any_instance_of(PagSeguro::Query).to receive_messages(transaction_data: transaction_data) }
    let(:transaction){ PagSeguro::Query.new("mail", "token", "trans_code") }
    subject{ PagSeguro::Query }

    it_behaves_like "a transaction"
  end

  describe "::find" do
    it "raises error without valid credentials" do
      expect { PagSeguro::Query.find nil, nil }.to raise_error(RestClient::Exception, "401 Unauthorized")
    end

    context "with abandoned set to false" do
      it "should try to fetch transactions" do
        params = double(:params)
        allow(PagSeguro::Query).to receive_messages(search_params: params)
        expect(RestClient).to receive(:get).with("https://ws.pagseguro.uol.com.br/v2/transactions", params: params)
        PagSeguro::Query.find "email", "token"
      end
    end

    context "with abandoned set to true" do
      it "should try to fetch abandoned transactions" do
        params = double(:params)
        allow(PagSeguro::Query).to receive_messages(search_params: params)
        expect(RestClient).to receive(:get).with("https://ws.pagseguro.uol.com.br/v2/transactions/abandoned", params: params)
        PagSeguro::Query.find "email", "token", abandoned: true
      end
    end

    context "with a stubbed response" do
      before { allow(RestClient).to receive_messages(get: transactions_xml) }
      subject{ PagSeguro::Query.find "email", "token", options: true }

      it "calls search_url with received options" do
        expect(PagSeguro::Query).to receive(:search_params).with("email", "token", {options: true})
        PagSeguro::Query.find "email", "token", options: true
      end

      it{ is_expected.to be_a Array }
      it'has 2 transactions' do
        expect(subject.size).to eq(2)
      end
      it("should have transaction ids"){ expect(subject.map(&:id)).to eq(["REF1234", "REF5678"]) }
    end
  end

  describe "::search_params" do
    it("returns an Hash"){ expect(PagSeguro::Query.search_params("email", "token")).to be_a Hash }

    context "with default options" do
      let(:search_params) { PagSeguro::Query.search_params("email", "token") }
      it { expect(search_params.keys).not_to include :maxPageResults }
      it { expect(search_params.keys).not_to include :page }
      it { expect(search_params[:finalDate]).to include Date.today.iso8601 }
      it { expect(search_params[:initialDate]).to include Date.yesterday.iso8601 }

      it "should call parse_dates" do
        expect(PagSeguro::Query).to receive(:parse_dates)
        search_params
      end
    end

    context "with page number set to 2" do
      let(:search_params){ PagSeguro::Query.search_params("email", "token", page: 2) }
      it { expect(search_params[:page]).to eq(2) }
    end

    context "with max_page_results set to 100" do
      let(:search_params){ PagSeguro::Query.search_params("email", "token", max_page_results: 100) }
      it { expect(search_params[:maxPageResults]).to eq(100) }
    end

    context "with initial_date set to 20 days ago" do
      let(:search_params){ PagSeguro::Query.search_params("email", "token", initial_date: 20.days.ago) }
      it { expect(search_params[:initialDate]).to include 20.days.ago.iso8601 }
    end

    context "with final_date set to 10 days ago" do
      let(:search_params){ PagSeguro::Query.search_params("email", "token", initial_date: 20.days.ago, final_date: 10.days.ago) }
      it { expect(search_params[:finalDate]).to include 10.days.ago.iso8601 }
    end
  end

  describe "::parse_dates" do
    it "raises error if initial date is less than 6 months ago" do
      expect {
        PagSeguro::Query.parse_dates initial_date: 7.months.ago
      }.to raise_error("Invalid initial date. Must be bigger than 6 months ago")
    end

    it "raises error if final date is bigger than today" do
      expect {
        PagSeguro::Query.parse_dates final_date: 1.day.from_now
      }.to raise_error("Invalid end date. Must be less than today")
    end

    it "raises error if final date is less than initial date" do
      expect {
        PagSeguro::Query.parse_dates initial_date: 30.days.ago, final_date: 31.days.ago
      }.to raise_error("Invalid end date. Must be bigger than initial date")
    end

    it "raises error if final date is bigger than initial date in more than 30 days" do
      expect {
        PagSeguro::Query.parse_dates initial_date: 32.days.ago, final_date: 1.day.ago
      }.to raise_error("Invalid end date. Must not differ from initial date in more than 30 days")
    end

    context "first return argument" do
      it "returns yesterday if no initial date was given" do
        expect(PagSeguro::Query.parse_dates.first).to eq((Time.now - 1.day).iso8601)
      end

      it "returns the initial date in iso8601 format if provided" do
        expect(PagSeguro::Query.parse_dates(initial_date: 3.days.ago).first).to eq(3.days.ago.iso8601)
      end
    end

    context "second return argument" do
      it "returns initial_date + 1 day no final date was given" do
        expect(PagSeguro::Query.parse_dates(initial_date: 2.days.ago).last).to eq(1.day.ago.iso8601)
      end

      it "returns the final date in iso8601 format if provided" do
        expect(PagSeguro::Query.parse_dates(initial_date: 3.days.ago, final_date: 2.days.ago).last).to eq(2.days.ago.iso8601)
      end
    end
  end
end
