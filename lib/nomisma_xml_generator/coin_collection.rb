# frozen_string_literal: true

module NomismaXmlGenerator
  ##
  # PUL's entire collection of coins, generated from a directory full of JSON
  #  files pulled from the catalog.
  class CoinCollection
    attr_reader :json_dir

    def initialize(json_dir)
      @json_dir = json_dir
    end
  end
end
