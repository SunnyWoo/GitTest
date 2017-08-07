# == Schema Information
#
# Table name: factories
#
#  id            :integer          not null, primary key
#  code          :string(255)
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  contact_email :text
#  locale        :string(255)
#

class Factory < ActiveRecord::Base
  strip_attributes only: %i(code name)
  include Logcraft::Trackable

  has_many :shelves
  has_many :factory_members
  has_many :omniauths, as: :owner, dependent: :destroy
  has_many :file_gateways
  has_many :product_models
  has_many :print_items, through: :product_models
  has_many :shelf_materials
  has_many :shelf_categories
  has_many :batch_flows

  has_one :ftp_gateway, dependent: :destroy
  accepts_nested_attributes_for :ftp_gateway

  # Factory 可以設定的 locale
  LOCALES = %w(zh-TW zh-CN en).freeze
  validates :locale, presence: true, inclusion: { in: Factory::LOCALES }

  def dropbox
    omniauths.find_by(provider: 'dropbox')
  end

  delegate :oauth_token, :oauth_secret, to: :dropbox, prefix: true, allow_nil: true

  def dropbox_client
    @dropbox ||= Dropbox::API::Client.new token: dropbox_oauth_token, secret: dropbox_oauth_secret
  end

  def set_dropbox_access_token(access_token)
    client = Dropbox::API::Client.new token: access_token.token, secret: access_token.secret
    save_omniauth(access_token, client.account.uid)
  end

  private

  def save_omniauth(access_token, uid)
    omniauth = omniauths.where(provider: 'dropbox', uid: uid.to_s).first_or_initialize
    omniauth.oauth_token = access_token.token
    omniauth.oauth_secret = access_token.secret
    omniauth.uid = uid
    omniauth.save!
  end
end
