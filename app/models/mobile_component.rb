# == Schema Information
#
# Table name: mobile_components
#
#  id             :integer          not null, primary key
#  mobile_page_id :integer
#  key            :string(255)
#  parent_id      :integer
#  position       :integer
#  image          :string(255)
#  contents       :json
#  created_at     :datetime
#  updated_at     :datetime
#

class MobileComponent < ActiveRecord::Base
  serialize :contents, Hashie::Mash.pg_json_serializer

  acts_as_list scope: [:mobile_page_id]
  default_scope { order('position ASC') }

  validates :key, presence: true, if: 'mobile_page_id.present?'
  belongs_to :mobile_page, touch: true

  has_many :sub_components, class_name: 'SubMobileComponent', foreign_key: :parent_id
  accepts_nested_attributes_for :sub_components, allow_destroy: true

  mount_uploader :image, DefaultWithMetaUploader

  KEYS = %w(kv ticker product_line redeem campaign_section products_section tab_section media_section create_section
            description_section download_section campaign_background)
  CAMPAIGN_TYPES = %w(subject limited_time limited_quantity)
  PRODUCT_TYPES = %w(type_a type_b type_c)
  PRODUCT_FILTER = %w(designer tag collection)
  TAB_CATEGORIES = %w(create shop download)
  ACTION_TYPES = %w(web shop create campaign)

  CONTENT_KEYS = {
    campaign_id: :select,
    product_id: :string,
    work_uuid: :select,
    designer_id: :select,
    tag_id: :select,
    collection_id: :select,
    tab_category: :select,
    media_type: :select,
    product_category_key: :select,
    product_model_key: :select,
    title: :string,
    link: :string,
    content: :string,
    section_title: :string,
    section_color: :minicolors,
    product_type: :string,
    product_filter: :string,
    campaign_type: :string,
    desc_short: :string,
    action_text: :string,
    tip_text: :string,
    media_url: :string,
    description: :text,
    download_url: :string,
    will_sale_text: :string,
    on_sale_text: :string,
    create_text: :string,
    shop_text: :string,
    download_text: :string,
    action_type: :select,
    action_target: :string,
    action_key: :string
  }

  # TODO: 這裡確定是用 campaign_id 找 MobilePage, 將來要重構成更適當的名稱.
  def campaign
    MobilePage.find(contents.campaign_id) if contents.campaign_id.present?
  end

  # TODO: 同上, 用 product_id 找 Work, 也該改, 但你覺得會有那麼一天嗎?
  def work
    included = [:previews, :price_tier, :user,
                category: [:translations],
                product: [:currencies, :translations, :customized_special_price_tier, :price_tier]]
    work = nil
    work = StandardizedWork.includes(included).find_by(uuid: contents.work_uuid) if contents.work_uuid.present?
    work = Work.includes(included).find(contents.product_id) if work.nil? && contents.product_id.present?
    work
  end

  # 這裡是對的 (你真的相信柱姐嗎?)
  def designer
    Designer.find(contents.designer_id) if contents.designer_id.present?
  end

  def designer_works
    designer.standardized_works.includes(included_list).published.with_available_product
  end

  def tag
    Tag.find(contents.tag_id) if contents.tag_id.present?
  end

  def tag_works
    tag.standardized_works.includes(included_list).published.with_available_product
  end

  def collection
    Collection.find(contents.collection_id) if contents.collection_id.present?
  end

  def collection_works
    collection.standardized_works.includes(included_list).published.with_available_product
  end

  def contents_tip_text
    contents.tip_text.present? ? contents.tip_text : ''
  end

  def contents_will_sale_text
    contents.will_sale_text.present? ? contents.will_sale_text : '即將開賣'
  end

  def contents_on_sale_text
    contents.on_sale_text.present? ? contents.on_sale_text : '馬上搶'
  end

  private

  def included_list
    [:previews, :price_tier, :user,
     category: [:translations],
     product: [:currencies, :translations, :customized_special_price_tier, :price_tier],
     taggings: [tag: :translations]]
  end
end
