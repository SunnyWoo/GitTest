class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :key
      t.string :title
      t.string :desc
      t.string :designer_username
      t.string :artworks_class
      t.json :wordings
      t.text :about_designer
      t.timestamps
    end
    add_index :campaigns, :key
  end
end
