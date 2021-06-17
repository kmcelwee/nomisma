# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CatalogScraper do
  let(:scraper) { described_class.new(output_dir: $output_dir) }

  it 'has an output directory' do
    expect(scraper).instance_of? NomismaXmlGenerator::CatalogScraper
    expect(scraper.output_dir).to eq $output_dir
    expect(File.directory?(scraper.output_dir)).to eq true

    default_scraper = described_class.new
    expect(default_scraper.output_dir).to eq 'data/raw'
  end
end
