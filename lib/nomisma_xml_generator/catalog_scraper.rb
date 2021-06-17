# frozen_string_literal: true

require 'faraday'

module NomismaXmlGenerator
  ##
  # Executes scrape of the PUL coin collection and saves JSON
  #  to the given output directory. This requires first collecting all coin
  #  identifiers from the catalog list page, and then querying the raw data
  #  for each of those coins on their detail pages.
  class CatalogScraper
    attr_reader :output_dir

    def initialize(output_dir: "data/raw")
      @output_dir = output_dir
    end

    def max_page
      @max_page ||= scrape_max_page
    end

    def coin_list
      @coin_list ||= scrape_coin_list
    end

    def scrape_max_page
      get_json_from_page(1)["meta"]["pages"]["total_pages"]
    end

    def url_page(page)
      "https://catalog.princeton.edu/catalog?f[format][]=Coin&format=json&per_page=100&page=#{page}"
    end

    def get_json_from_page(page)
      response = Faraday.get url_page(page)
      JSON.parse(response.body)
    end

    def get_coins_from_page(page)
      coin_json = get_json_from_page(page)['data']
      coin_ids = []
      coin_json.each do |coin|
        coin_ids << coin["links"]["self"]
      end
      coin_ids
    end

    def scrape_coin_list
      coin_list = []
      Array(1..max_page).each do |page|
        coin_list.push(*get_coins_from_page(page))
      end
      coin_list
    end
  end
end
