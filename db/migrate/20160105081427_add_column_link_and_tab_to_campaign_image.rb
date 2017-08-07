class AddColumnLinkAndTabToCampaignImage < ActiveRecord::Migration
  def change
    add_column :campaign_images, :link, :string
    add_column :campaign_images, :open_in_new_tab, :boolean, default: false
  end
end
