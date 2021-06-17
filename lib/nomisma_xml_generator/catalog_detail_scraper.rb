# frozen_string_literal: true

module NomismaXmlGenerator
  ##
  # Given a list of coin links (which can be provided by CatalogListScraper)
  #  collect all the raw JSON attached to each coin in the list
  class CatalogDetailScraper
    attr_reader :output_dir

    def initialize(output_dir: 'data/raw')
      @output_dir = output_dir
    end
  end
end
