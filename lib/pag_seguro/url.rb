module PagSeguro
  class Url
    class << self
      attr_accessor :environment
    end

    self.environment = :production

    def self.uris
      @uris ||= {
        production: {
          api: "https://ws.pagseguro.uol.com.br/v2",
          site: "https://pagseguro.uol.com.br/v2"
        },
        sandbox: {
          api: "https://ws.sandbox.pagseguro.uol.com.br/v2",
          site: "https://sandbox.pagseguro.uol.com.br/v2"
        }
      }
    end

    def self.root_uri(type)
      root = uris.fetch(environment.to_sym) { raise InvalidEnvironmentError }
      root[type.to_sym]
    end

    def self.api_url(path)
      File.join(root_uri(:api), path)
    end

    def self.site_url(path)
      File.join(root_uri(:site), path)
    end
    InvalidEnvironmentError = Class.new(StandardError)
  end
end
