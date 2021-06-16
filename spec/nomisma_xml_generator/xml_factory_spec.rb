# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::XmlFactory do
  let(:factory) { described_class.new }

  it 'can be instantiated' do
    expect(factory).instance_of? NomismaXmlGenerator::XmlFactory
  end
end
