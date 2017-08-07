class CreateRecommendSorts < ActiveRecord::Migration
  def change
    create_table :recommend_sorts do |t|
      t.string :design_platform
      t.string :sort
      t.timestamps
    end

    %w(ios android website).each do |design_platform|
      RecommendSort.create(design_platform: design_platform, sort: 'new')
    end
  end
end
