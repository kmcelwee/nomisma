# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::Cli do
  let(:cli) { described_class.new }
  let(:list_scraper) { NomismaXmlGenerator::CatalogListScraper.new }
  let(:output_dir) { "#{$output_dir}/raw" }

  before(:each) do
    [1, 2, 3].each do |page|
      catalog_fixture = File.read("#{$fixture_path}/coin_list_fixtures/catalog#{page}.json")
      catalog_response = JSON.parse(catalog_fixture)
      stub_request(:get, "https://catalog.princeton.edu/catalog?f[format][]=Coin&format=json&per_page=100&page=#{page}")
        .to_return(status: 200, body: catalog_response.to_json)
    end

    list_scraper.coin_list.each do |coin_url|
      coin_path = File.join($fixture_path, "coin_detail_fixtures", "#{coin_url.split('/')[-1]}.json")
      coin_file = File.read(coin_path)
      catalog_response = JSON.parse(coin_file)
      stub_request(:get, coin_url + '/raw')
        .to_return(status: 200, body: catalog_response.to_json)
    end
  end

  it 'scrapes the list of coin data from the catalog and writes coin list' do
    expected_path = File.join($output_dir, 'coin-list.txt')
    File.delete expected_path if File.exist? expected_path
    options = { output_dir: $output_dir }
    cli.invoke(:scrape_catalog_list, [], options)
    expect(File.exist?(expected_path)).to eq(true)

    expect(File.readlines(expected_path).length).to eq($unique_fixture_count)
  end

  it 'scrapes the detail coin data' do
    Dir[output_dir].each do |file|
      File.delete(file) unless File.directory? file
    end

    options = { output_dir: output_dir }
    cli.invoke(:scrape_catalog_detail, [], options)

    expected_path = "#{output_dir}/coin-15190.json"
    expect(File.exist?(expected_path)).to eq true

    # TODO: There are duplicates in the first three pages of the catalog fixture?
    expect(Dir["#{output_dir}/*"].length).to eq $unique_fixture_count
  end

  it 'generates the xml' do
    expected_path = File.join($output_dir, 'princeton-nomisma.rdf')
    File.delete expected_path if File.exist? expected_path

    # TODO: this needs to be named better
    options = { json_dir: output_dir, output_dir: $output_dir }
    cli.invoke(:generate_xml, [], options)

    expect(File.exist?(expected_path)).to eq true
  end
end
