# frozen_string_literal: true

require 'nokogiri'
require 'rdf/rdfxml'
require 'rdf/vocab'

module NomismaXmlGenerator
  ##
  # Given a coin collection, generate the XML that follows Nomisma conventions.
  class XmlFactory
    attr_reader :coin_collection

    def initialize(coin_collection)
      @coin_collection = coin_collection
    end

    def graph
      @graph ||= generate_graph
    end

    def generate_graph
      @graph = RDF::Graph.new
      coin_collection.all_coins.each do |coin|
        add_coin_to_graph(coin)
      end
      graph
    end

    def add_coin_to_graph(coin)
      coin_element = RDF::URI.new(coin.full_link)
      @graph << RDF::Statement(coin_element, RDF::Vocab::DC.title, RDF::Literal.new(coin.title))
      @graph << RDF::Statement(coin_element, RDF::Vocab::DC.identifier, RDF::Literal.new(coin.identifier))
      # NMO = Namespace("http://nomisma.org/ontology#")

      # g.bind("dcterms", DCTERMS)
      # g.bind("nmo", NMO)
      # g.bind("void", VOID)

      # g.add((coin, RDF.type, NMO.NumismaticObject))
      # g.add((coin, NMO.ObjectType, Literal("coin")))
      # g.add((coin, VOID.inDataset,
      #  URIRef("https://library.princeton.edu/special-collections/databases/princeton-numismatic-collection-database")))

      # if coin.reference_link
      #   g.add((coin, NMO.hasTypeSeriesItem, URIRef(r['reference_link'])))
      # if coin.diameter
      #   g.add((coin, NMO.hasDiameter, Literal(r["diameter"], datatype=XSD.decimal)))
      # if coin.weight
      #   g.add((coin, NMO.hasWeight, Literal(r["weight"], datatype=XSD.decimal)))
      # if coin.axis
      #   g.add((coin, NMO.hasAxis, Literal(int(r["axis"]), datatype=XSD.integer)))
      # if coin.material
      #   g.add((coin, NMO.hasMaterial, Literal(r["material"])))

      coin_element
    end

    def write_xml(path)
      RDF::RDFXML::Writer.open(path) do |writer|
        writer << graph
      end
    end
  end
end
