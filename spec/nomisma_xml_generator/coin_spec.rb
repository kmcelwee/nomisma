# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::Coin do
  it 'creates a coin class' do
    coin = NomismaXmlGenerator::Coin.new('test')
    expect(coin).instance_of? NomismaXmlGenerator::Coin
  end
end
