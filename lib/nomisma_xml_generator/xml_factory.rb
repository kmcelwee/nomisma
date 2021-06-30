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
      # g.bind("dcterms", DCTERMS)
      # g.bind("nmo", NMO)
      # g.bind("void", VOID)

      nmo = RDF::Vocabulary.new("http://nomisma.org/ontology#")
      void = RDF::Vocabulary.new("http://rdfs.org/ns/void#")
      dc = RDF::Vocab::DC

      coin_element = RDF::URI.new(coin.full_link)
      @graph << RDF::Statement(coin_element, RDF.type, nmo.NumismaticObject)
      @graph << RDF::Statement(coin_element, dc.title, RDF::Literal.new(coin.title))
      @graph << RDF::Statement(coin_element, dc.identifier, RDF::Literal.new(coin.identifier))
      @graph << RDF::Statement(coin_element, nmo.ObjectType, RDF::Literal.new("coin"))

      numismatics_collection_link = "https://library.princeton.edu/special-collections/databases/princeton-numismatic-collection-database"
      @graph << RDF::Statement(coin_element, void.inDataset, RDF::URI.new(numismatics_collection_link))

      if coin.diameter
        @graph << RDF::Statement(coin_element, nmo.hasDiameter, RDF::Literal.new(coin.diameter, datatype: RDF::XSD.decimal))
      end
      @graph << RDF::Statement(coin_element, nmo.hasWeight, RDF::Literal.new(coin.weight, datatype: RDF::XSD.decimal)) if coin.weight
      @graph << RDF::Statement(coin_element, nmo.hasAxis, RDF::Literal.new(coin.axis, datatype: RDF::XSD.decimal)) if coin.axis
      @graph << RDF::Statement(coin_element, nmo.hasMaterial, RDF::Literal.new(coin.material)) if coin.material

      coin_element
    end

    def write_xml(path)
      RDF::RDFXML::Writer.open(path) do |writer|
        writer << graph
      end
    end
  end
end
