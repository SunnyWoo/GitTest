#
#  可以在application.yml 設定多個 host
#  elasticsearch:
#    - 'localhost:9200'
#    - '192.168.1.1:9200'
#
Elasticsearch::Model.client = Elasticsearch::Client.new hosts: Settings.elasticsearch