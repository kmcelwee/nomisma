# frozen_string_literal: true

require 'json'

module NomismaXmlGenerator
  ##
  # The coin information that will be stored for the Nomisma XML, generated
  #  from the catalog
  class Coin
    attr_reader :json_path

    def initialize(coin_json_path)
      @json_path = coin_json_path
    end

    def catalog_hash
      @catalog_hash ||= generate_catalog_hash
    end

    def generate_catalog_hash
      file = File.read(@json_path)
      JSON.parse(file)
    end

    def identifier
      catalog_hash['id']
    end

    def safely_grab_array_value(key, substitute: nil)
      value = catalog_hash.fetch(key, nil)
      return substitute unless value

      value[0]
    end

    def title
      alternate_title = identifier.capitalize.gsub('-', ' ')
      safely_grab_array_value('pub_created_display', substitute: alternate_title)
    end

    def weight
      safely_grab_array_value('weight_s')
    end

    def axis
      safely_grab_array_value('die_axis_s')
    end

    def diameter
      safely_grab_array_value('size_s')
    end

    def material
      safely_grab_array_value('issue_metal_s')
    end

    def full_link
      "https://catalog.princeton.edu/catalog/" + identifier
    end
    # df["reference_link"] = df["full_link"].apply(lambda x: self.reference_mapper.get(x))
  end
end
