# frozen_string_literal: true

require 'json'

module NomismaXmlGenerator
  ##
  # The coin information that will be stored for the Nomisma XML, generated
  #  from the catalog
  class Coin
    attr_reader :json_path

    def initialize(coin_json_path)
      @json_path = coin_json_path
    end

    def catalog_hash
      @catalog_hash ||= generate_catalog_hash
    end

    def generate_catalog_hash
      file = File.read(@json_path)
      JSON.parse(file)
    end
  end
end
