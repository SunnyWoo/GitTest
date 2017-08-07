# == Schema Information
#
# Table name: header_link_tags
#
#  id             :integer          not null, primary key
#  header_link_id :integer
#  style          :string(255)
#  position       :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class HeaderLinkTag < ActiveRecord::Base
  include MissingLocalesBuilder

  belongs_to :header_link, touch: true

  acts_as_list :position

  translates :title, fallbacks_for_empty_translations: true
  globalize_accessors
  accepts_nested_attributes_for :translations

  STYLE = %w(primary success warning danger default info)

  default_scope { order('position ASC') }
end
