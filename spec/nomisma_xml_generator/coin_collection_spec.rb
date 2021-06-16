# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CoinCollection do
  let(:coin_json_dir) { $fixture_path.to_s }
  let(:coin_collection) { described_class.new(coin_json_dir) }

  it 'to have a path to coin JSON' do
    expect(coin_collection).instance_of? NomismaXmlGenerator::CoinCollection

    expect(coin_collection.json_dir).to eq(coin_json_dir)
  end
end
