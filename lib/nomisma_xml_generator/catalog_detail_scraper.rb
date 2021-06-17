# frozen_string_literal: true

module NomismaXmlGenerator
  ##
  # Given a list of coin links (which can be provided by CatalogListScraper)
  #  collect all the raw JSON attached to each coin in the list
  class CatalogDetailScraper
    attr_reader :output_dir, :coin_list

    def initialize(coin_list, output_dir: 'data/raw')
      @output_dir = output_dir
      @coin_list = coin_list
    end

    def scrape_coin(coin_url)
      coin_url += '/raw'
      response = Faraday.get coin_url
      JSON.parse(response.body)
    end
  end
end
