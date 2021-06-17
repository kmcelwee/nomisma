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

    def xml
      @xml ||= generate_xml
    end

    def generate_xml
      s = RDF::URI.new("https://rubygems.org/gems/rdf")
      p = RDF::Vocab::DC.creator
      o = RDF::URI.new("http://ar.to/#self")
      RDF::Statement(s, p, o)
    end

    def write_xml(path)
      RDF::RDFXML::Writer.open(path) do |writer|
        writer << xml
      end
    end
  end
end
