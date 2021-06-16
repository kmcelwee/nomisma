# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::XmlFactory do
  let(:coin_collection) { NomismaXmlGenerator::CoinCollection.new($fixture_path.to_s) }
  let(:factory) { described_class.new(coin_collection) }

  it 'contains a CoinCollection' do
    expect(factory).instance_of? NomismaXmlGenerator::XmlFactory
    expect(factory.coin_collection).instance_of? NomismaXmlGenerator::CoinCollection
  end
end
