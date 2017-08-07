class CreateCampaignImages < ActiveRecord::Migration
  def change
    create_table :campaign_images do |t|
      t.belongs_to :campaign
      t.string :key
      t.string :file
      t.string :desc
      t.timestamps
    end
    add_index :campaign_images, :campaign_id
    add_index :campaign_images, :key
  end
end
