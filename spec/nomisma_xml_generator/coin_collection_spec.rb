# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CoinCollection do
  let(:coin_collection) { described_class.new }

  it 'is instantiated' do
    expect(coin_collection).instance_of? NomismaXmlGenerator::CoinCollection
  end
end
