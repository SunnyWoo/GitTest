# == Schema Information
#
# Table name: reviews
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  work_id    :integer
#  work_type  :string(255)
#  body       :text
#  star       :integer
#  created_at :datetime
#  updated_at :datetime
#

class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :work, polymorphic: true

  validates :body, length: 1..800
  validates :star, numericality: { greater_than_or_equal_to: 1,
                                   less_than_or_equal_to: 5 }

  scope :ordered, -> { order('created_at ASC') }
  scope :ordered_desc, -> { order('created_at DESC') }
  scope :earlier, ->(time) { where('created_at > ?', time) }
end
