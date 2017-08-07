# == Schema Information
#
# Table name: header_links
#
#  id                    :integer          not null, primary key
#  parent_id             :integer
#  href                  :string(255)
#  link_type             :string(255)
#  spec_id               :integer
#  position              :integer
#  blank                 :boolean          default(FALSE), not null
#  dropdown              :boolean          default(FALSE), not null
#  created_at            :datetime
#  updated_at            :datetime
#  row                   :integer
#  auto_generate_product :boolean          default(FALSE), not null
#

class HeaderLink < ActiveRecord::Base
  include MissingLocalesBuilder

  has_many :tags, class_name: 'HeaderLinkTag', dependent: :destroy
  has_many :children, class_name: 'HeaderLink', foreign_key: :parent_id
  belongs_to :parent, class_name: 'HeaderLink', touch: true

  validate :child_presence_row
  validate :confirm_two_nested
  before_destroy :forbid_destroy_with_children

  acts_as_list :position

  translates :title, fallbacks_for_empty_translations: true
  globalize_accessors
  accepts_nested_attributes_for :translations
  accepts_nested_attributes_for :tags, allow_destroy: true

  default_scope { order('position ASC') }
  scope :root, -> { where(parent_id: nil) }
  scope :rows, -> { pluck(:row).uniq.sort }

  include AASM

  aasm column: :link_type do
    state :text
    state :url
    state :create
  end

  def root?
    parent.nil?
  end

  private

  def confirm_two_nested
    return unless more_than_two_nested?
    errors.add(:parent_id, 'not confirm two nested!')
  end

  def child_presence_row
    return if parent_id.blank?
    return if row.present?
    errors.add(:rwo, 'not confirm blank!')
  end

  def more_than_two_nested?
    parent_id? && children.size > 0
  end

  def forbid_destroy_with_children
    return if children.size == 0
    errors.add(:base, 'forbid destroy with children!')
    false
  end
end
