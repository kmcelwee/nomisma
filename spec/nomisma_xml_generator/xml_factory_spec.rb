# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::XmlFactory do
  let(:coin_collection) { NomismaXmlGenerator::CoinCollection.new("#{$fixture_path}/coin_detail_fixtures") }
  let(:factory) { described_class.new(coin_collection) }

  it 'contains a CoinCollection' do
    expect(factory).instance_of? NomismaXmlGenerator::XmlFactory
    expect(factory.coin_collection).instance_of? NomismaXmlGenerator::CoinCollection
  end

  it 'contains xml' do
    expect(factory.graph).instance_of? RDF::Statement
  end

  it 'writes xml to a file' do
    expect(File.exist?($xml_output_file)).to eq false
    factory.write_xml($xml_output_file)
    expect(File.exist?($xml_output_file)).to eq true
  end
end
