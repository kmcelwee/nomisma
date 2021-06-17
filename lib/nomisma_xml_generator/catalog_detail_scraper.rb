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

    def write_coin_json(coin_url)
      output_path = File.join(@output_dir, "#{coin_url.split('/')[-1]}.json")
      coin_json = scrape_coin(coin_url)

      File.open(output_path, 'w') do |f|
        f.write(coin_json.to_json)
      end
    end

    def collect_all_coins
      coin_list.each do |coin_url|
        write_coin_json(coin_url)
      end
    end
  end
end
