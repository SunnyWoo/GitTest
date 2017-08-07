class AddCouponDescToBdevetn < ActiveRecord::Migration
  def up
    Bdevent.add_translation_fields! coupon_desc: :string
  end
  def down
    remove_column :bdevetn_translations, :coupon_desc
  end
end
