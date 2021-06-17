# frozen_string_literal: true

module NomismaXmlGenerator
  ##
  # Executes scrape of the PUL coin collection and saves JSON
  #  to the given output directory
  class CatalogScraper
    attr_reader :output_dir

    def initialize(output_dir: "data/raw")
      @output_dir = output_dir
    end
  end
end
