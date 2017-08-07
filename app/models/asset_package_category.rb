# == Schema Information
#
# Table name: asset_package_categories
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  available       :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#  packages_count  :integer          default(0)
#  downloads_count :integer          default(0)
#

class AssetPackageCategory < ActiveRecord::Base
  include MissingLocalesBuilder
  validates_associated :translations
  validate :required_locale_translaion_exist?

  has_many :packages, class_name: 'AssetPackage', foreign_key: :category_id

  translates :name
  globalize_accessors
  accepts_nested_attributes_for :translations, allow_destroy: true

  Translation.class_eval do
    validates :name, presence: true, if: -> (translation) {  translation.locale.in? [:en, :'zh-TW'] }
  end

  protected

  def required_locale_translaion_exist?
    flag = [:en, :'zh-TW'].all? { |value| translations.map(&:locale).include? value }
    errors.add(:base, 'WTF no en or zh_TW?') unless flag
  end
end
