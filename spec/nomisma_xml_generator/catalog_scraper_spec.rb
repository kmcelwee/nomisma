# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CatalogScraper do
  let(:scrape_output_dir) { "#{$output_dir}/raw" }
  let(:scraper) { described_class.new(output_dir: scrape_output_dir) }
  before(:each) do
    [1, 2, 3].each do |page|
      catalog_fixture = File.read("#{$fixture_path}/catalog_fixtures/catalog#{page}.json")
      catalog_response = JSON.parse(catalog_fixture)
      stub_request(:get, "https://catalog.princeton.edu/catalog?f[format][]=Coin&format=json&per_page=100&page=#{page}")
        .to_return(status: 200, body: catalog_response.to_json)
    end
  end

  it 'has an output directory' do
    expect(scraper).to be_a_kind_of NomismaXmlGenerator::CatalogScraper
    expect(scraper.output_dir).to eq scrape_output_dir
    expect(File.directory?(scraper.output_dir)).to eq true

    default_scraper = described_class.new
    expect(default_scraper.output_dir).to eq 'data/raw'
  end

  it 'gets the max page' do
    expect(scraper.max_page).to eq 3
  end

  it 'scrapes from the list page' do
    expect(scraper.get_json_from_page(1)).to be_a_kind_of Hash
  end

  it 'collects the list of coins' do
    expect(scraper.coin_list).to include("https://catalog.princeton.edu/catalog/coin-1521")
    expect(scraper.coin_list.length).to eq 300
  end
end
