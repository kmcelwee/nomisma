# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CoinCollection do
  let(:coin_json_dir) { "#{$fixture_path}/coin_detail_fixtures" }
  let(:coin_collection) { described_class.new(coin_json_dir) }

  it 'to have a path to coin JSON' do
    expect(coin_collection).instance_of? NomismaXmlGenerator::CoinCollection

    expect(coin_collection.json_dir).to eq(coin_json_dir)
  end

  it 'to have a list of all json paths' do
    paths = coin_collection.all_json_paths
    expect(paths).instance_of? Array
    expect(paths).to include("#{$fixture_path}/coin_detail_fixtures/coin-11036.json")
    expect(paths).to include("#{$fixture_path}/coin_detail_fixtures/coin-9099.json")
  end

  it 'has a size value' do
    expect(coin_collection.size).to eq(290)
  end

  it 'to generate a list of coin objects' do
    all_coins = coin_collection.all_coins
    expect(all_coins).instance_of? Array
    expect(all_coins.length).to eq(290)

    single_coin = all_coins[0]
    expect(single_coin).instance_of? NomismaXmlGenerator::Coin
  end
end
