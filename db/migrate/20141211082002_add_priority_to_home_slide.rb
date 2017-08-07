class AddPriorityToHomeSlide < ActiveRecord::Migration
  def change
    add_column :home_slides, :priority, :integer, default: 1
    HomeSlide.enabled.order('created_at ASC').each_with_index do |hs, i|
      p = i+1
      p = 10 if p > 10
      hs.update! priority: p
    end
  end
end
