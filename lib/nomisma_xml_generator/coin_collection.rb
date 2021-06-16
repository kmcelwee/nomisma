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

    def all_coins
      @all_coins ||= generate_coin_list
    end

    def all_json_files
      Dir["#{@json_dir}/*.json"]
    end

    def generate_coin_list
      NomismaXmlGenerator::Coin()
    end
  end
end
