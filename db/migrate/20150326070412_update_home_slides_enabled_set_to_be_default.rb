class UpdateHomeSlidesEnabledSetToBeDefault < ActiveRecord::Migration
  def up
    HomeSlide.enabled.update_all set: :default
  end

  def down
  end
end
