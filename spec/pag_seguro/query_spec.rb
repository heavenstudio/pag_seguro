# encoding: utf-8

require 'spec_helper'

describe PagSeguro::Query do
  let(:transactions_xml){ File.open( File.expand_path( File.dirname(__FILE__) + '/../fixtures/transaction_history.xml') ) }

  describe "instance" do
    before { PagSeguro::Query.any_instance.stub(transaction_data: transaction_data) }
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
        PagSeguro::Query.stub(search_params: params)
        RestClient.should_receive(:get).with("https://ws.pagseguro.uol.com.br/v2/transactions", params: params)
        PagSeguro::Query.find "email", "token"
      end
    end

    context "with abandoned set to true" do
      it "should try to fetch abandoned transactions" do
        params = double(:params)
        PagSeguro::Query.stub(search_params: params)
        RestClient.should_receive(:get).with("https://ws.pagseguro.uol.com.br/v2/transactions/abandoned", params: params)
        PagSeguro::Query.find "email", "token", abandoned: true
      end
    end

    context "with a stubbed response" do
      before { RestClient.stub(get: transactions_xml) }
      subject{ PagSeguro::Query.find "email", "token", options: true }

      it "calls search_url with received options" do
        PagSeguro::Query.should_receive(:search_params).with("email", "token", {options: true})
        PagSeguro::Query.find "email", "token", options: true
      end

      it{ should be_a Array }
      it{ should have(2).transactions }
      it("should have transaction ids"){ subject.map(&:id).should == ["REF1234", "REF5678"] }
    end
  end

  describe "::search_params" do
    it("returns an Hash"){ PagSeguro::Query.search_params("email", "token").should be_a Hash }

    context "with default options" do
      let(:search_params) { PagSeguro::Query.search_params("email", "token") }
      it { search_params.keys.should_not include :maxPageResults }
      it { search_params.keys.should_not include :page }
      it { search_params[:finalDate].should include Date.today.iso8601 }
      it { search_params[:initialDate].should include Date.yesterday.iso8601 }

      it "should call parse_dates" do
        PagSeguro::Query.should_receive(:parse_dates)
        search_params
      end
    end

    context "with page number set to 2" do
      let(:search_params){ PagSeguro::Query.search_params("email", "token", page: 2) }
      it { search_params[:page].should == 2 }
    end

    context "with max_page_results set to 100" do
      let(:search_params){ PagSeguro::Query.search_params("email", "token", max_page_results: 100) }
      it { search_params[:maxPageResults].should == 100 }
    end

    context "with initial_date set to 20 days ago" do
      let(:search_params){ PagSeguro::Query.search_params("email", "token", initial_date: 20.days.ago) }
      it { search_params[:initialDate].should include 20.days.ago.iso8601 }
    end

    context "with final_date set to 10 days ago" do
      let(:search_params){ PagSeguro::Query.search_params("email", "token", initial_date: 20.days.ago, final_date: 10.days.ago) }
      it { search_params[:finalDate].should include 10.days.ago.iso8601 }
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
        PagSeguro::Query.parse_dates.first.should == (Time.now - 1.day).iso8601
      end

      it "returns the initial date in iso8601 format if provided" do
        PagSeguro::Query.parse_dates(initial_date: 3.days.ago).first.should == 3.days.ago.iso8601
      end
    end

    context "second return argument" do
      it "returns initial_date + 1 day no final date was given" do
        PagSeguro::Query.parse_dates(initial_date: 2.days.ago).last.should == 1.day.ago.iso8601
      end

      it "returns the final date in iso8601 format if provided" do
        PagSeguro::Query.parse_dates(initial_date: 3.days.ago, final_date: 2.days.ago).last.should == 2.days.ago.iso8601
      end
    end
  end
end
