# == Schema Information
#
# Table name: taggings
#
#  id            :integer          not null, primary key
#  taggable_id   :integer
#  tag_id        :integer
#  created_at    :datetime
#  updated_at    :datetime
#  taggable_type :string(255)
#  position      :integer
#

class Tagging < ActiveRecord::Base
  belongs_to :taggable, polymorphic: true
  belongs_to :tag

  after_commit :touch_work

  scope :work_taggings, -> { where(taggable_type: %w(Work StandardizedWork)) }

  private

  def touch_work
    return unless taggable_type.in? %w(Work StandardizedWork)
    taggable.touch
  end
end
