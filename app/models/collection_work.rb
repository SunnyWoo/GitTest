# == Schema Information
#
# Table name: collection_works
#
#  id            :integer          not null, primary key
#  collection_id :integer
#  work_id       :integer
#  created_at    :datetime
#  updated_at    :datetime
#  work_type     :string(255)
#  position      :integer
#

class CollectionWork < ActiveRecord::Base
  belongs_to :collection
  belongs_to :work, polymorphic: true

  after_commit :touch_work

  private

  def touch_work
    work.touch
  end
end
