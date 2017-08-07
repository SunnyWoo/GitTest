class CreateMobileCampaigns < ActiveRecord::Migration
  def change
    create_table :mobile_campaigns do |t|
      t.string :kv
      t.string :title
      t.string :desc_short
      t.string :ticker
      t.string :campaign_type
      t.datetime :publish_at
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :is_enabled, default: false
      t.integer :position
      t.timestamps
    end
  end
end
