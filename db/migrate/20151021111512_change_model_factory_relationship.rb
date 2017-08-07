class ChangeModelFactoryRelationship < ActiveRecord::Migration
  def up
    add_reference :product_models, :factory, index: true

    ProductModelFactoryMapping.find_each do |mapping|
      next if mapping.product_model.nil?
      mapping.product_model.update(factory: mapping.factory)
    end

    drop_table :product_model_factory_mappings
  end

  class ProductModel < ActiveRecord::Base
    has_many :factories, -> { distinct }, through: :product_model_factory_mappings
    has_many :product_model_factory_mappings, foreign_key: :product_model_id
    belongs_to :factory
  end

  class Factory < ActiveRecord::Base
    has_many :product_models, through: :product_model_factory_mappings
    has_many :product_model_factory_mappings, foreign_key: :factory_id
  end

  class ProductModelFactoryMapping < ActiveRecord::Base
    belongs_to :factory, foreign_key: :factory_id
    belongs_to :product_model, foreign_key: :product_model_id
  end
end
