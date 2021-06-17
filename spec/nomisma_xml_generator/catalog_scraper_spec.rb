# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CatalogScraper do
  let(:scraper) { described_class.new }

  it 'is instantiated' do
    expect(scraper).instance_of? NomismaXmlGenerator::CatalogScraper
  end
end
