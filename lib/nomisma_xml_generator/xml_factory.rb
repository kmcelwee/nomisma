# frozen_string_literal: true

module NomismaXmlGenerator
  ##
  # Given a coin collection, generate the XML that follows Nomisma conventions.
  class XmlFactory
    attr_reader :coin_collection

    def initialize(coin_collection)
      @coin_collection = coin_collection
    end
  end
end
