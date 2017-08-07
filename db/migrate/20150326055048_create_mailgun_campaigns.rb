class CreateMailgunCampaigns < ActiveRecord::Migration
  def change
    create_table :mailgun_campaigns do |t|
      t.string  :name
      t.string  :campaign_id
      t.boolean :is_mailgun_create, default: false
      t.json    :report
      t.timestamps
    end
  end
end
