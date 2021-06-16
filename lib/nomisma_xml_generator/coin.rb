# frozen_string_literal: true

module NomismaXmlGenerator
  ##
  # The coin information that will be stored for the Nomisma XML, generated
  #  from the catalog
  class Coin
    attr_reader :json_path

    def initialize(coin_json_path)
      @json_path = coin_json_path
    end
  end
end
