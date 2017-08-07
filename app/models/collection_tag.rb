# == Schema Information
#
# Table name: collection_tags
#
#  id            :integer          not null, primary key
#  collection_id :integer
#  tag_id        :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class CollectionTag < ActiveRecord::Base
  belongs_to :collection
  belongs_to :tag

  after_commit :touch_tag

  private

  def touch_tag
    tag.touch
  end
end
