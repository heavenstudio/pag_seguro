# encoding: UTF-8
require "spec_helper"

describe PagSeguro::PreApproval do
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
  it { should validate_presence_of :final_date }
  it { should validate_presence_of :max_amount_per_period }
  it { should validate_presence_of :max_total_amount }

  [:weekly, :monthly, :bimonthly, :trimonthly, :semiannually, :yearly].each do |period_type|
    it { should allow_value(period_type).for(:period) }
    it { should allow_value(period_type.to_s).for(:period) }
    it { should allow_value(period_type.to_s.upcase).for(:period) }
  end
  it { should_not allow_value(:some_other_period_type).for(:period) }

  it { should allow_value( nil ).for(:initial_date) }
  it { should_not allow_value( Time.now - 10.minutes ).for(:initial_date) }
  it { should allow_value( Time.now ).for(:initial_date) }
  it { should allow_value( (PagSeguro::PreApproval::DATE_RANGE - 5.minutes).from_now ).for(:initial_date) }
  it { should_not allow_value( PagSeguro::PreApproval::DATE_RANGE.from_now + 5.minutes ).for(:initial_date) }

  it { should_not allow_value( nil ).for(:final_date) }
  it { should_not allow_value( Time.now - 10.minutes ).for(:final_date) }
  it { should allow_value( Time.now ).for(:final_date) }
  it { should allow_value( (PagSeguro::PreApproval::DATE_RANGE - 5.minutes).from_now ).for(:final_date) }
  it { should_not allow_value( PagSeguro::PreApproval::DATE_RANGE.from_now + 5.minutes ).for(:final_date) }

  context "with an initial date" do
    subject { PagSeguro::PreApproval.new(initial_date: 5.days.from_now) }

    it { should_not allow_value( nil ).for(:final_date) }
    it { should_not allow_value( Time.now - 10.minutes + 5.days ).for(:final_date) }
    it { should allow_value( Time.now + 5.days ).for(:final_date) }
    it { should allow_value( (PagSeguro::PreApproval::DATE_RANGE - 5.minutes + 5.days).from_now ).for(:final_date) }
    it { should_not allow_value( PagSeguro::PreApproval::DATE_RANGE.from_now + 5.minutes + 5.days ).for(:final_date) }
  end

  describe "initialized with minimum attributes" do
    subject{ build :minimum_pre_approval }
    it { should be_valid }
  end

  describe "initialized with attributes" do
    subject{ build :pre_approval }

    it { should be_valid }
    its(:name){ should == "Super seguro para notebook" }
    its(:details){ should == "Toda segunda feira será cobrado o valor de R$150,00 para o seguro do notebook" }
    its(:amount_per_payment){ should == '150.00' }
    its(:initial_date){ Date.new(2015, 1, 17) }
    its(:final_date){ Date.new(2017, 1, 17) }
    its(:max_amount_per_period){ should == '200.00' }
    its(:max_total_amount){ should == '900.00' }
    its(:review_URL){ should == "http://sounoob.com.br/produto1" }

    context "weekly" do
      subject{ build :weekly_pre_approval }

      it { should ensure_inclusion_of(:day_of_week).in_array(%w(monday tuesday wednesday thursday friday saturday sunday)) }

      its(:period){ should == 'weekly' }
      its(:day_of_week){ should == 'monday' }
      it { should be_weekly }
      it { should_not be_monthly }
      it { should_not be_yearly }

    end

    context "monthly" do
      subject{ build :monthly_pre_approval }

      it { should ensure_inclusion_of(:day_of_month).in_range(1..28) }

      its(:period){ should == 'monthly' }
      its(:day_of_month){ should == 3 }
      it { should_not be_weekly }
      it { should be_monthly }
      it { should_not be_yearly }
    end

    context "yearly" do
      subject{ build :yearly_pre_approval }

      it { should validate_presence_of(:day_of_year) }
      it { should allow_value('10-22').for(:day_of_year) }
      it { should allow_value('01-01').for(:day_of_year) }
      it { should allow_value(PagSeguro::DayOfYear.new(month: 1, day: 1)).for(:day_of_year) }
      it { should_not allow_value('1-1').for(:day_of_year) }
      it { should_not allow_value("10-22\nanything").for(:day_of_year) }

      its(:period){ should == 'yearly' }
      its(:day_of_year){ should == '03-01' }
      it { should_not be_weekly }
      it { should_not be_monthly }
      it { should be_yearly }
    end
  end
end
