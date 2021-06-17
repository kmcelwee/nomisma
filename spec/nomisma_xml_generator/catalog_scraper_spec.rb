# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CatalogScraper do
  let(:scraper) { described_class.new(output_dir: $output_dir) }
  before(:each) do
    catalog_fixture = File.read("#{$fixture_path}/catalog_fixtures/catalog.json")
    catalog_response = JSON.parse(catalog_fixture)
    stub_request(:get, "https://catalog.princeton.edu/catalog?f[format][]=Coin&format=json&per_page=100&page=1")
      .to_return(status: 200, body: catalog_response.to_json)
  end

  it 'has an output directory' do
    expect(scraper).to be_a_kind_of NomismaXmlGenerator::CatalogScraper
    expect(scraper.output_dir).to eq $output_dir
    expect(File.directory?(scraper.output_dir)).to eq true

    default_scraper = described_class.new
    expect(default_scraper.output_dir).to eq 'data/raw'
  end

  it 'gets the max page' do
    expect(scraper.max_page).to eq 141
  end

  it 'scrapes a page' do
    expect(scraper.get_json_from_page(1)).to be_a_kind_of Hash
  end
end
