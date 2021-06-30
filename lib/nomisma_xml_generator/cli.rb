# frozen_string_literal: true

require 'thor'

module NomismaXmlGenerator
  ##
  # Command line interface for generating numsimatic RDF
  class Cli < Thor
    desc 'scrape_and_generate_rdf', 'Collect all coin information and generate RDF'
    def scrape_and_generate_rdf; end

    desc 'scrape_coins', 'Collect all coin information from the catalog list and detail pages'
    def scrape_coins; end

    desc 'generate_rdf', 'Use the coins in data/raw to generate RDF for nomisma'
    def generate_rdf; end
  end
end
