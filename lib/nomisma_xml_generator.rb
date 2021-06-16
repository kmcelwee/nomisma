# frozen_string_literal: true

require 'nomisma_xml_generator/coin'

##
# Scrape the catalog and combine with the PUL Numismatics team's spreadsheet
#  in order to generate XML to publish to Nomisma
module NomismaXmlGenerator
  autoload(:Coin, File.join(__FILE__, 'coin'))
end
