# frozen_string_literal: true

require 'nomisma_xml_generator/coin'
require 'nomisma_xml_generator/coin_collection'
require 'nomisma_xml_generator/xml_factory'
require 'nomisma_xml_generator/catalog_scraper'

##
# Scrape the catalog and combine with the PUL Numismatics team's spreadsheet
#  in order to generate XML to publish to Nomisma
module NomismaXmlGenerator
  autoload(:Coin, File.join(__FILE__, 'coin'))
  autoload(:CoinCollection, File.join(__FILE__, 'coin_collection'))
  autoload(:XmlFactory, File.join(__FILE__, 'xml_factory'))
  autoload(:CatalogScraper, File.join(__FILE__, 'catalog_scraper'))
end
