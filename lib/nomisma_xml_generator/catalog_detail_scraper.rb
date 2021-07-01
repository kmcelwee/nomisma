# frozen_string_literal: true

module NomismaXmlGenerator
  ##
  # Given a list of coin links (which can be provided by CatalogListScraper)
  #  collect all the raw JSON attached to each coin in the list
  class CatalogDetailScraper
    attr_reader :output_dir, :coin_list, :progress_file_path, :continue, :coin_list_path

    def initialize(coin_list_path, output_dir: 'data/raw', continue: false)
      @output_dir = output_dir
      @continue = continue
      @coin_list_path = coin_list_path
      @progress_file_path = File.join(output_dir, '..', 'coin-list-progress.txt')
      @coin_list = generate_coin_list
    end

    def generate_coin_list
      full_coin_list = File.readlines(@coin_list_path).each(&:strip!)
      if @continue
        # if continuing a previous run remove the urls that have already been scraped
        completed_urls = File.readlines(@progress_file_path).each(&:strip!)
        full_coin_list.reject { |url| completed_urls.include? url }
      else
        # empty the contents of the progress folder if you need to restart
        File.open(@progress_file_path, 'w') {}
        # Return the full coin_list if we're not continuing a past run
        full_coin_list
      end
    end

    def log_scrape(coin_url)
      File.open(@progress_file_path, 'a') do |f|
        f << coin_url.delete_suffix('/raw') + "\n"
      end
      puts "Scraped: #{coin_url}"
    end

    def scrape_coin(coin_url)
      coin_url += '/raw'
      response = Faraday.get coin_url
      raise "REQUEST ERROR: #{response.status}, COIN_URL: #{coin_url}" if response.status != 200

      log_scrape(coin_url)
      JSON.parse(response.body)
    end

    def write_coin_json(coin_url)
      output_path = File.join(@output_dir, "#{coin_url.split('/')[-1]}.json")
      coin_json = scrape_coin(coin_url)

      File.open(output_path, 'w') do |f|
        f.write(coin_json.to_json)
      end
    end

    # TODO: name change to "scrape_all_coins"
    def collect_all_coins
      coin_list.each do |coin_url|
        write_coin_json(coin_url)
      end
    end
  end
end
