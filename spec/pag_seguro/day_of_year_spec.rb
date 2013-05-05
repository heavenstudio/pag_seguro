# encoding: UTF-8
require "spec_helper"

describe PagSeguro::DayOfYear do
  it { should have_attribute_accessor(:day) }
  it { should have_attribute_accessor(:month) }

  context "initialized with attributes" do
    subject{ build :day_of_year, month: 10, day: 21 }

    its(:month){ should == 10 }
    its(:day){ should == 21 }
  end

  describe "#to_s" do
    it "should output format MM-dd" do
      build(:day_of_year, month: 11, day: 21).to_s.should == "11-21"
      build(:day_of_year, month: 1, day: 21).to_s.should  == "01-21"
      build(:day_of_year, month: 11, day: 1).to_s.should  == "11-01"
      build(:day_of_year, month: 1, day: 1).to_s.should   == "01-01"
    end

    it "should raise error if month is bigger than 13" do
      expect {
        build(:day_of_year, month: 13, day: 21).to_s
      }.to raise_error(PagSeguro::Error::InvalidDayOfYear, "DateOfYear should be a valid date: (month: 13, day: 21)")
    end

    it "should raise error if day is bigger than 31" do
      expect {
        build(:day_of_year, month: 1, day: 32).to_s
      }.to raise_error(PagSeguro::Error::InvalidDayOfYear, "DateOfYear should be a valid date: (month: 1, day: 32)")
    end
  end

  describe "comparisons" do
    it "should be bigger when month is ahead" do
      build(:day_of_year, month: 2).should be > build(:day_of_year, month: 1)
    end

    it "should be bigger when day is ahead if month is the same" do
      build(:day_of_year, day: 2).should be > build(:day_of_year, day: 1)
    end

    it "should be equal if both day and month are the same" do
      build(:day_of_year).should be == build(:day_of_year)
    end
  end
end
