# encoding: UTF-8
require "spec_helper"

describe PagSeguro::DayOfYear do
  it { should have_attribute_accessor(:day) }
  it { should have_attribute_accessor(:month) }

  context "initialized with attributes" do
    subject{ PagSeguro::DayOfYear.new(month: 10, day: 21) }

    its(:month){ should == 10 }
    its(:day){ should == 21 }
  end

  describe "#to_s" do
    it "should output format MM-dd" do
      PagSeguro::DayOfYear.new(month: 11, day: 21).to_s.should == "11-21"
      PagSeguro::DayOfYear.new(month: 1, day: 21).to_s.should  == "01-21"
      PagSeguro::DayOfYear.new(month: 11, day: 1).to_s.should  == "11-01"
      PagSeguro::DayOfYear.new(month: 1, day: 1).to_s.should   == "01-01"
    end

    it "should raise error if month is bigger than 13" do
      expect {
        PagSeguro::DayOfYear.new(month: 13, day: 21).to_s
      }.to raise_error(PagSeguro::Error::InvalidDayOfYear, "DateOfYear should be a valid date: (month: 13, day: 21)")
    end

    it "should raise error if day is bigger than 31" do
      expect {
        PagSeguro::DayOfYear.new(month: 1, day: 32).to_s
      }.to raise_error(PagSeguro::Error::InvalidDayOfYear, "DateOfYear should be a valid date: (month: 1, day: 32)")
    end
  end

  describe "comparisons" do
    it "should be bigger when month is ahead" do
      PagSeguro::DayOfYear.new(month: 2, day: 1).should be > PagSeguro::DayOfYear.new(month: 1, day: 1)
    end

    it "should be bigger when day is ahead if month is the same" do
      PagSeguro::DayOfYear.new(month: 1, day: 2).should be > PagSeguro::DayOfYear.new(month: 1, day: 1)
    end

    it "should be equal if both day and month are the same" do
      PagSeguro::DayOfYear.new(month: 1, day: 1).should be == PagSeguro::DayOfYear.new(month: 1, day: 1)
    end
  end
end