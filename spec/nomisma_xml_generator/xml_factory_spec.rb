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
    File.delete $xml_output_file if File.exist? $xml_output_file
    factory.write_xml($xml_output_file)
    expect(File.exist?($xml_output_file)).to eq true
  end

  it 'builds a graph with the correct triples' do
    # TODO: This can be done better.
    coin_triples = []
    factory.graph.triples.each do |triple|
      coin_triples << triple if triple[0].value == "https://catalog.princeton.edu/catalog/coin-9099"
    end

    expect(coin_triples.length).to eq(9)
  end
end
