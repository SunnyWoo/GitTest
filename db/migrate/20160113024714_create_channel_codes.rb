class CreateChannelCodes < ActiveRecord::Migration
  def change
    create_table :channel_codes do |t|
      t.string :description
      t.string :code

      t.timestamps
    end
  end
end
