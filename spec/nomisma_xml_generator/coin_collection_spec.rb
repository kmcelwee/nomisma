# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CoinCollection do
  let(:coin_json_dir) { $fixture_path.to_s }
  let(:coin_collection) { described_class.new(coin_json_dir) }

  it 'to have a path to coin JSON' do
    expect(coin_collection).instance_of? NomismaXmlGenerator::CoinCollection

    expect(coin_collection.json_dir).to eq(coin_json_dir)
  end

  it 'to have a list of all json files' do
    files = coin_collection.all_json_files
    expect(files).instance_of? Array
    expect(files).to include("#{$fixture_path}/coin-11036.json")
    expect(files).to include("#{$fixture_path}/coin-9099.json")
  end

  it 'to generate a list of coin objects' do
  end
end
