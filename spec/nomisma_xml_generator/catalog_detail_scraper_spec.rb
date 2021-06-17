# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CatalogDetailScraper do
  let(:scraper) { described_class.new }

  it 'can be instantiated' do
    expect(scraper).to be_a_kind_of NomismaXmlGenerator::CatalogDetailScraper
  end
end
