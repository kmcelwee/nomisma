# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CatalogDetailScraper do
  let(:output_dir) { "#{$output_dir}/raw" }
  let(:list_scraper) { NomismaXmlGenerator::CatalogListScraper.new }

  before(:each) do
    [1, 2, 3].each do |page|
      catalog_fixture = File.read("#{$fixture_path}/catalog_fixtures/catalog#{page}.json")
      catalog_response = JSON.parse(catalog_fixture)
      stub_request(:get, "https://catalog.princeton.edu/catalog?f[format][]=Coin&format=json&per_page=100&page=#{page}")
        .to_return(status: 200, body: catalog_response.to_json)
    end

    list_scraper.coin_list.each do |coin_url|
      coin_path = File.join($fixture_path, "coin_detail_fixtures", "#{coin_url.split('/')[-1]}.json")
      coin_file = File.read(coin_path)
      catalog_response = JSON.parse(coin_file)
      stub_request(:get, coin_url + '/raw')
        .to_return(status: 200, body: catalog_response.to_json)
    end
  end

  it 'has an output directory and a list of coin URLs' do
    detail_scraper = described_class.new(list_scraper.coin_list, output_dir: output_dir)

    expect(detail_scraper).to be_a_kind_of NomismaXmlGenerator::CatalogDetailScraper
    expect(detail_scraper.output_dir).to eq output_dir
  end

  it 'can scrape a coin url' do
    detail_scraper = described_class.new(list_scraper.coin_list, output_dir: output_dir)
    coin_url = 'https://catalog.princeton.edu/catalog/coin-15039'
    coin_details = detail_scraper.scrape_coin(coin_url)
    expect(coin_details).to be_a_kind_of Hash

    expect(coin_details["weight_s"]).to eq(["22.04"])
  end
end
