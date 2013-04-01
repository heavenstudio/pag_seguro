# encoding: UTF-8
require "spec_helper"

describe PagSeguro::PreApproval do
  let(:shared_attributes) do
    {
      name: "Super seguro para notebook",
      details: "Toda segunda feira será cobrado o valor de R$150,00 para o seguro do notebook",
      amount_per_payment: 150.00,
      initial_date: Date.new(2015, 1, 17),
      final_date: Date.new(2017, 1, 17),
      max_amount_per_period: 200.00,
      max_total_amount: 900.00,
      review_URL: "http://sounoob.com.br/produto1"
    }
  end
  let(:weekly_attributes){ shared_attributes.merge(period: :weekly, day_of_week: :monday) }
  let(:monthly_attributes){ shared_attributes.merge(period: :monthly, day_of_month: 3) }
  let(:yearly_attributes){ shared_attributes.merge(period: :yearly, day_of_year: PagSeguro::DayOfYear.new(day: 1, month: 3)) }

  it { should have_attribute_accessor(:name) }
  it { should have_attribute_accessor(:details) }
  it { should have_attribute_accessor(:amount_per_payment) }
  it { should have_attribute_accessor(:period) }
  it { should have_attribute_accessor(:day_of_week) }
  it { should have_attribute_accessor(:day_of_month) }
  it { should have_attribute_accessor(:day_of_year) }
  it { should have_attribute_accessor(:initial_date) }
  it { should have_attribute_accessor(:final_date) }
  it { should have_attribute_accessor(:max_amount_per_period) }
  it { should have_attribute_accessor(:max_total_amount) }
  it { should have_attribute_accessor(:review_URL) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :period }

  [:weekly, :monthly, :bimonthly, :trimonthly, :semiannually, :yearly].each do |period_type|
    it { should allow_value(period_type).for(:period) }
    it { should allow_value(period_type.to_s).for(:period) }
    it { should allow_value(period_type.to_s.upcase).for(:period) }
  end
  it { should_not allow_value(:some_other_period_type).for(:period) }

  it { should allow_value( nil ).for(:initial_date) }
  it { should_not allow_value( Time.now - 10.minutes ).for(:initial_date) }
  it { should allow_value( Time.now ).for(:initial_date) }
  it { should allow_value( (2.years - 5.minutes).from_now ).for(:initial_date) }
  it { should_not allow_value( 2.years.from_now + 5.minutes ).for(:initial_date) }

  it { should allow_value( nil ).for(:final_date) }
  it { should_not allow_value( Time.now - 10.minutes ).for(:final_date) }
  it { should allow_value( Time.now ).for(:final_date) }
  it { should allow_value( (2.years - 5.minutes).from_now ).for(:final_date) }
  it { should_not allow_value( 2.years.from_now + 5.minutes ).for(:final_date) }

  context "with an initial date" do
    subject { PagSeguro::PreApproval.new(initial_date: 5.days.from_now) }

    it { should allow_value( nil ).for(:final_date) }
    it { should_not allow_value( Time.now - 10.minutes + 5.days ).for(:final_date) }
    it { should allow_value( Time.now + 5.days ).for(:final_date) }
    it { should allow_value( (2.years - 5.minutes + 5.days).from_now ).for(:final_date) }
    it { should_not allow_value( 2.years.from_now + 5.minutes + 5.days ).for(:final_date) }    
  end

  describe "initialized with attributes" do
    subject{ PagSeguro::PreApproval.new(shared_attributes) }

    its(:name){ should == "Super seguro para notebook" }
    its(:details){ should == "Toda segunda feira será cobrado o valor de R$150,00 para o seguro do notebook" }
    its(:amount_per_payment){ should == 150.00 }
    its(:initial_date){ Date.new(2015, 1, 17) }
    its(:final_date){ Date.new(2017, 1, 17) }
    its(:max_amount_per_period){ should == 200.00 }
    its(:max_total_amount){ should == 900.00 }
    its(:review_URL){ should == "http://sounoob.com.br/produto1" }

    context "weekly" do
      subject{ PagSeguro::PreApproval.new(weekly_attributes) }

      it { should ensure_inclusion_of(:day_of_week).in_array(%w(monday tuesday wednesday thursday friday saturday sunday)) }

      its(:period){ should == 'weekly' }
      its(:day_of_week){ should == 'monday' }
    end

    context "monthly" do
      subject{ PagSeguro::PreApproval.new(monthly_attributes) }

      it { should ensure_inclusion_of(:day_of_month).in_range(1..28) }

      its(:period){ should == 'monthly' }
      its(:day_of_month){ should == 3 }
    end

    context "yearly" do
      subject{ PagSeguro::PreApproval.new(yearly_attributes) }

      it { should validate_presence_of(:day_of_year) }
      it { should allow_value('10-22').for(:day_of_year) }
      it { should allow_value('01-01').for(:day_of_year) }
      it { should allow_value(PagSeguro::DayOfYear.new(month: 1, day: 1)).for(:day_of_year) }
      it { should_not allow_value('1-1').for(:day_of_year) }

      its(:period){ should == 'yearly' }
      its(:day_of_year){ should == '03-01' }
    end
  end
end