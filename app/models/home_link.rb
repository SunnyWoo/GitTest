# == Schema Information
#
# Table name: home_links
#
#  id         :integer          not null, primary key
#  href       :string(255)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

class HomeLink < ActiveRecord::Base
  include MissingLocalesBuilder

  validates_presence_of :href, :name, locale: :en
  validates :href, url: true

  acts_as_list :position

  acts_as_list add_new_at: :top
  default_scope { order('position ASC') }

  translates :name, fallbacks_for_empty_translations: true
  globalize_accessors
  accepts_nested_attributes_for :translations
end
