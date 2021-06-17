# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CatalogDetailScraper do
  let(:output_dir) { "#{$output_dir}/raw" }
  let(:scraper) { described_class.new(output_dir: output_dir) }

  it 'has an output directory' do
    expect(scraper).to be_a_kind_of NomismaXmlGenerator::CatalogDetailScraper
    expect(scraper.output_dir).to eq output_dir
  end
end
