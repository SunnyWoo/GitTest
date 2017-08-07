class CreateMobileCampaignTranslationTable < ActiveRecord::Migration
  def up
    MobileCampaign.create_translation_table!(kv: :string, title: :string, desc_short: :string,  ticker: :string)
  end

  def down
    MobileCampaign.drop_translation_table!
  end
end
