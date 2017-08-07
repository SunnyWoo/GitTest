# == Schema Information
#
# Table name: home_blocks
#
#  id         :integer          not null, primary key
#  template   :string(255)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

class HomeBlock < ActiveRecord::Base
  translates :title
  globalize_accessors
  acts_as_list

  has_many :items, ->{ ordered }, class_name: 'HomeBlockItem', foreign_key: :block_id, dependent: :destroy

  VALID_TEMPLATES = %w(collection_2 collection_3 collection_4).freeze

  validates :template, inclusion: VALID_TEMPLATES

  before_validation :assign_default_template

  scope :ordered, -> { order('position ASC') }

  private

  def assign_default_template
    self.template ||= VALID_TEMPLATES.first
  end
end
