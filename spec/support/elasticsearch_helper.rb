require 'elasticsearch/extensions/test/cluster/tasks'

RSpec.configure do |config|
  cluster = Elasticsearch::Extensions::Test::Cluster

  # Make sure the cluster is running
  config.before :each, elasticsearch: true do
    begin
      client = Elasticsearch::Client.new
      client.cluster.health
    rescue => _
      cluster.start(nodes: 1, port: 9200) unless cluster.running?(on: 9200)
    end
  end

  # Make sure the elasticsearch index is clean before and after tests
  config.around :each, elasticsearch: true do |example|
    models = [Work, User]
    models.each(&:initialize_elasticsearch)

    example.run

    models.each do |m|
      m.__elasticsearch__.client.indices.delete index: m.index_name
    end
  end

  # Make sure the cluster is stop
  config.after :suite do
    cluster.stop(port: 9200) if cluster.running?(on: 9200)
  end
end
