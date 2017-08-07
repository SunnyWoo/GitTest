# == Schema Information
#
# Table name: bdevent_works
#
#  id         :integer          not null, primary key
#  bdevent_id :integer
#  work_id    :integer
#  work_type  :string(255)
#  info       :json
#  image      :string(255)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

class BdeventWork < ActiveRecord::Base
  belongs_to :bdevent
  belongs_to :work, polymorphic: true

  validates :bdevent_id, uniqueness: { scope: :work_id }
  store_accessor :info, %w(title)

  mount_uploader :image, BdeventWorkUploader
  acts_as_list scope: :bdevent

  default_scope { order('position DESC') }

  delegate :name, to: :work, prefix: true, allow_nil: true

  def work_title
    title.present? ? title : work_name
  end

  def work_image
    image.present? ? image : work.order_image
  end
end
