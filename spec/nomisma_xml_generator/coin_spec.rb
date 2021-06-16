# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::Coin do
  let(:coin_json_path) { "#{$fixture_path}/coin-9099.json" }

  it 'has a path to a JSON file' do
    coin = NomismaXmlGenerator::Coin.new(coin_json_path)
    expect(coin).instance_of? NomismaXmlGenerator::Coin
    expect(File.exist?(coin.json_path))
  end
end
