# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::Coin do
  let(:coin_id) { "coin-9099" }
  let(:coin_json_path) { "#{$fixture_path}/#{coin_id}.json" }
  let(:coin) { described_class.new(coin_json_path) }

  it 'has a path to a JSON file and parses JSON' do
    expect(coin).instance_of? NomismaXmlGenerator::Coin
    expect(File.exist?(coin.json_path))

    catalog_hash = coin.catalog_hash
    expect(catalog_hash).instance_of? Hash
    expect(catalog_hash['id']).to eq(coin_id)
  end
end
