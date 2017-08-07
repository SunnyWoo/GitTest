class ElasticsearchImport < ActiveRecord::Migration
  def change
    StandardizedWork.import_elasticsearch
  end
end
