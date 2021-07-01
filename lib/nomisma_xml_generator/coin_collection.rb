# frozen_string_literal: true

require 'csv'

module NomismaXmlGenerator
  ##
  # PUL's entire collection of coins, generated from a directory full of JSON
  #  files pulled from the catalog.
  class CoinCollection
    attr_reader :json_dir

    def initialize(json_dir, coin_list_path: nil)
      @json_dir = json_dir
      @coin_list_path = coin_list_path
    end

    # TODO: rename to coin_list
    def all_coins
      @all_coins ||= generate_coin_list
    end

    def all_json_paths
      # Get the list of coins from the given txt file, otherwise take the entire
      #  JSON directory of raw coin files
      if @coin_list_path
        coin_ids = File.readlines(@coin_list_path).map { |x| x.split('/')[-1].strip }
        return coin_ids.map { |coin_id| "#{@json_dir}/#{coin_id}.json" }
      end
      Dir["#{@json_dir}/*.json"]
    end

    def size
      all_json_paths.length
    end

    def reference_link_mapper(csv_path)
      reference_link_mapper = {}
      table = CSV.parse(File.read(csv_path), headers: true)
      table.each do |row|
        reference_link = row['Reference link']
        next unless reference_link

        if !reference_link.include?(' ') && reference_link.start_with?('http')
          reference_link_mapper[row['Catalog link']] = reference_link
        end
      end
      reference_link_mapper
    end

    def apply_reference_link(csv_path)
      mapper = reference_link_mapper(csv_path)
      all_coins.each do |coin|
        coin.reference_link = mapper[coin.full_link]
      end
    end

    def generate_coin_list
      coin_list = []
      all_json_paths.each do |path|
        coin_list.append(NomismaXmlGenerator::Coin.new(path))
      end
      coin_list
    end
  end
end
