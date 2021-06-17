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
  end

  it 'has an output directory and a list of coin URLs' do
    detail_scraper = described_class.new(list_scraper.coin_list, output_dir: output_dir)

    expect(detail_scraper).to be_a_kind_of NomismaXmlGenerator::CatalogDetailScraper
    expect(detail_scraper.output_dir).to eq output_dir
  end
end
