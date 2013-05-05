# encoding: UTF-8
require "spec_helper"

describe PagSeguro::Sender do
  context "instance" do
    it { should have_attribute_accessor(:email) }
    it { should have_attribute_accessor(:name) }
    it { should have_attribute_accessor(:phone_ddd) }
    it { should have_attribute_accessor(:phone_number) }

    context "initialized with all attributes" do
      subject { PagSeguro::Sender.new attributes_for(:sender) }
      its(:name){ should == "Stefano Diem Benatti" }
      its(:email){ should == "stefano@heavenstudio.com.br" }
      its(:phone_ddd){ should == 11 }
      its(:phone_number){ should == 993430994 }
    end

    context "with invalid e-mail" do
      subject { build :sender, email: "nothing" }
      its(:email){ should be_nil }
    end

    context "with nil name" do
      subject { build :sender, name: nil }
      it { should_not be_a_valid_name }
      its(:name){ should be_nil }
    end

    context "with name Joao" do
      subject { build :sender, name: "Joao" }
      it { should_not be_a_valid_name }
      its(:name){ should be_nil }
    end

    context "with name Joao Paulo" do
      subject { build :sender, name: "Joao Paulo" }
      it { should be_a_valid_name }
      its(:name){ should == "Joao Paulo" }
    end

    context "with name João Paulo" do
      subject { build :sender, name: "João Paulo" }
      it { should be_a_valid_name }
      its(:name){ should == "João Paulo" }
    end

    context "with very big name" do
      subject { build :sender, name: ("a" * 50)+" "+("b" * 10) }
      it { should be_a_valid_name }
      its(:name){ should == "a" * 50 }
    end

    context "with double spaces in name" do
      subject { build :sender, name: "Stefano   Benatti" }
      it { should be_a_valid_name }
      its(:name){ should == "Stefano Benatti" }
    end

    context "with invalid phone ddd" do
      subject { build :sender, phone_ddd: "111" }
      its(:phone_ddd){ should be_nil }
    end

    context "with invalid phone number" do
      subject { build :sender, phone_number: "1234567" }
      its(:phone_number){ should be_nil }
    end
  end
end
