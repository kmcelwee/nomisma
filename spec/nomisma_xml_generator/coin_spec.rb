# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::Coin do
  let(:coin_id) { "coin-9099" }
  let(:coin_json_path) { "#{$fixture_path}/coin_detail_fixtures/#{coin_id}.json" }
  let(:coin) { described_class.new(coin_json_path) }

  it 'has a path to a JSON file and parses JSON' do
    expect(coin).instance_of? NomismaXmlGenerator::Coin
    expect(File.exist?(coin.json_path)).to eq(true)

    catalog_hash = coin.catalog_hash
    expect(catalog_hash).instance_of? Hash
    expect(catalog_hash['id']).to eq(coin_id)
  end

  context 'collects correct values from catalog JSON' do
    let(:sparse_coin_path) { "#{$fixture_path}/coin_detail_fixtures/coin-11036.json" }
    let(:sparse_coin) { described_class.new(sparse_coin_path) }

    it 'has an identifier' do
      expect(coin.identifier).to eq(coin_id)
    end

    it 'has a title' do
      expect(coin.title).to eq("Trajan (98 to 117), sestertius, Rome")
    end

    it "uses the identifier as a title if the default field is empty" do
      expect(sparse_coin.title).to eq('Coin 11036')
    end

    it 'has a weight' do
      expect(coin.weight).to eq("22.49")
    end

    it "returns nil for certain values if there are none listed" do
      expect(sparse_coin.weight).to be_nil
      expect(sparse_coin.axis).to be_nil
      expect(sparse_coin.diameter).to be_nil
    end

    it 'has an axis' do
      expect(coin.axis).to eq("6")
    end

    it 'has a diameter' do
      expect(coin.diameter).to eq("31")
    end

    it 'has a material' do
      expect(coin.material).to eq("Orichalcum")
    end

    it 'has a full link' do
      expect(coin.full_link).to eq("https://catalog.princeton.edu/catalog/coin-9099")
    end

    it 'a reference link can be set' do
      expect(coin.reference_link).to eq(nil)
      coin.reference_link = 'http://numismatics.com/pella34556'
      expect(coin.reference_link).to eq('http://numismatics.com/pella34556')
    end
  end
end
