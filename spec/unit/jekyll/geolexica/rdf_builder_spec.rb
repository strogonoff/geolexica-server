# (c) Copyright 2020 Ribose Inc.
#

RSpec.describe ::Jekyll::Geolexica::RDFBuilder do
  let(:rdfb) { described_class.new(concept_10_data, site) }
  let(:concept_10_data) { load_concept_fixture("concept-10.yaml") }
  let(:site) { fake_site }

  it "initializes with a concept hash and site" do
    instance = described_class.new(concept_10_data, site)
    expect(instance).to be_kind_of(described_class)
    expect(instance.data).to eq(concept_10_data)
    expect(instance.site).to be(site)
  end

  specify "#graph returns an RDF Graph instance" do
    retval = rdfb.graph
    expect(retval).to be_kind_of(::RDF::Graph)
  end

  %w[9 10 1336].each do |concept_num|
    specify "#graph returns an RDF Graph with correct structure for " +
      "concept #{concept_num}" do
      expected = RDF::Graph.load(fixture_path("concept-#{concept_num}.ttl"))
      data = load_concept_fixture("concept-#{concept_num}.yaml")
      rdfb = described_class.new(data, site)

      expected_dump = expected.dump(:ttl)
      actual_dump = rdfb.graph.dump(:ttl)
      # TODO Should be, for easier reviewing:
      # actual_dump = rdfb.graph.dump(:ntriples)
      # expected_dump = expected.dump(:ntriples)
      expect(actual_dump).to eq(expected_dump)
    end
  end

  def load_concept_fixture(fixture_name)
    YAML.load(fixture(fixture_name))
  end

  def fake_site
    config_path = File.expand_path("../../../../_config.yml", __dir__)
    lang_data_path = File.expand_path("../../../../_data/lang.yaml", __dir__)
    config = YAML.load(File.read(config_path))
    lang_data = YAML.load(File.read(lang_data_path))

    double(
      config: config,
      data: {"lang" => lang_data},
    )
  end
end
