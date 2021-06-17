# frozen_string_literal: true

require 'faraday'

module NomismaXmlGenerator
  ##
  # Executes scrape of the PUL coin collection and saves JSON
  #  to the given output directory
  class CatalogScraper
    attr_reader :output_dir

    def initialize(output_dir: "data/raw")
      @output_dir = output_dir
    end

    def max_page
      @max_page ||= scrape_max_page
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
  end
end
