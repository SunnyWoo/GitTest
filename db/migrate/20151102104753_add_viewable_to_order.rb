class AddViewableToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :viewable, :boolean, default: true
    Order.update_all viewable: true
  end

  class Order < ActiveRecord::Base
  end
end
