class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.string     :name
      t.datetime   :delivery_at
      t.json       :filter
      t.string     :subject
      t.text       :content
      t.string     :locale
      t.belongs_to :mailgun_campaign
      t.timestamps
    end
  end
end
