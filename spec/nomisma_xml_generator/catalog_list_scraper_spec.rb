# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CatalogListScraper do
  let(:filename) { 'coin-list.txt' }
  let(:scraper) { described_class.new(output_dir: $output_dir) }
  before(:each) do
    [1, 2, 3].each do |page|
      catalog_fixture = File.read("#{$fixture_path}/coin_list_fixtures/catalog#{page}.json")
      catalog_response = JSON.parse(catalog_fixture)
      stub_request(:get, "https://catalog.princeton.edu/catalog?f[format][]=Coin&format=json&per_page=100&page=#{page}")
        .to_return(status: 200, body: catalog_response.to_json)
    end
  end

  it 'has an output directory' do
    expect(scraper).to be_a_kind_of NomismaXmlGenerator::CatalogListScraper
    expect(scraper.output_dir).to eq $output_dir
    expect(File.directory?(scraper.output_dir)).to eq true

    default_scraper = described_class.new
    expect(default_scraper.output_dir).to eq 'data'
  end

  it 'gets the max page' do
    expect(scraper.max_page).to eq 3
  end

  it 'scrapes from the list page' do
    expect(scraper.get_json_from_list_page(1)).to be_a_kind_of Hash
  end

  it 'collects the list of coins' do
    expect(scraper.coin_list).to include("https://catalog.princeton.edu/catalog/coin-1521")
    expect(scraper.coin_list.length).to eq 300
  end

  it 'writes list of coins to a txt file' do
    file_path = File.join($output_dir, filename)
    File.delete file_path if File.exist? file_path
    scraper.write_coin_list(filename: filename)
    expect(File.exist?(file_path)).to eq true
  end
end
