require 'spec_helper'

describe PagSeguro::Url do

  it "has a default environment" do
    expect(PagSeguro::Url.environment).to eq :production
  end

  it "should change the environment" do
    PagSeguro::Url.environment = :sandbox
    expect(PagSeguro::Url.environment).to eq :sandbox
  end

  describe ".api_url" do
    it "raises when environment has no endpoint" do
      PagSeguro::Url.environment = :invalid

      expect {
        PagSeguro::Url.api_url("/")
      }.to raise_exception(PagSeguro::Url::InvalidEnvironmentError)
    end

    it "returns api url" do
      PagSeguro::Url.environment = :production
      expect(PagSeguro::Url.api_url("/some/path")).to eql("https://ws.pagseguro.uol.com.br/v2/some/path")
    end

    it "returns sandbox api url" do
      PagSeguro::Url.environment = :sandbox
      expect(PagSeguro::Url.api_url("/some/path")).to eql("https://ws.sandbox.pagseguro.uol.com.br/v2/some/path")
    end
  end

  describe ".site_url" do
    it "raises when environment has no endpoint" do
      PagSeguro::Url.environment = :invalid

      expect {
        PagSeguro::Url.site_url("/")
      }.to raise_exception(PagSeguro::Url::InvalidEnvironmentError)
    end

    it "returns site url" do
      PagSeguro::Url.environment = :production
      expect(PagSeguro::Url.site_url("/some/path")).to eql("https://pagseguro.uol.com.br/v2/some/path")
    end

    it "returns sandbox site url" do
      PagSeguro::Url.environment = :sandbox
      expect(PagSeguro::Url.site_url("/some/path")).to eql("https://sandbox.pagseguro.uol.com.br/v2/some/path")
    end
  end
end
