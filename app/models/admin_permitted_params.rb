AdminPermittedParams = Struct.new(:params, :user) do
  [:user, :product_model, :currency_type, :coupon, :fee, :work,
   :admin, :question, :question_category, :site_setting, :order, :home_slide,
   :note, :order_search, :announcement, :notification, :layer, :mobile_ui,
   :home_link, :email_banner, :asset_package_category, :mask, :header_link,
   :collection, :tag, :recommend_sort, :promotion, :adjustment, :store, :reward].each do |model_name|
    define_method model_name do
      params.require(model_name).permit(send("#{model_name}_attrs"))
    end
  end

  def user_attrs
    [:role]
  end

  def product_model_attrs
    platforms = [:ios, :android, :website]
    ProductModel.globalize_attribute_names + [
      :category_id, :key, :slug, :available, :dir_name, :external_code, :placeholder_image,
      :price_tier_id, :customized_special_price_tier_id, :enable_white,
      :material, :weight, :auto_imposite, :factory_id, :width, :height, :dpi, :aasm_state,
      :background_image, :overlay_image,
      :shape, :alignment_points,
      :padding_top, :padding_right, :padding_bottom, :padding_left,
      :background_color, :remote_key, :print_image_mask, :remove_print_image_mask,
      :watermark, :remove_watermark, :spec_id, :material_id, :craft_id, :enable_composite_with_horizontal_rotation,
      :create_order_image_by_cover_image, :enable_back_image, :profit_id,
      design_platform: platforms,
      customize_platform: platforms,
      tag_ids: [],
      option_type_ids: [],
      description_images_attributes: [:id, :image, :_destroy]
    ]
  end

  def currency_type_attrs
    [:name, :code, :description, :rate, :precision]
  end

  def coupon_attrs
    [:quantity, :title, :code, :begin_at, :expired_at, :event, :usage_count_limit,
     :price_tier_id, :discount_type, :percentage, :condition, :apply_target,
     :user_usage_count_limit, :base_price_type, :apply_count_limit, :code_type, :code_length, :is_free_shipping,
     :is_not_include_promotion,
     coupon_rules_attributes: [:id, :quantity, :condition, :threshold_id, :bdevent_id,
                               product_model_ids: [], product_category_ids: [], designer_ids: [], work_gids: []]
    ]
  end

  def fee_attrs
    [:name, :description, currencies_attributes: [:id, :price, :code, :name]]
  end

  def work_attrs
    [:name, :description, :spec_id, :cover_image, :work_type, :user_id, :crop_x, :crop_y, :crop_h, :crop_w,
     :featured]
  end

  def admin_attrs
    [:password, :password_confirmation, :email]
  end

  def question_attrs
    [:question, :question_category_id, :answer]
  end

  def question_category_attrs
    [:name]
  end

  def site_setting_attrs
    [:key, :value, :description]
  end

  def order_attrs
    [:aasm_state, :invoice_state, :invoice_number, :invoice_memo, :invoice_number_created_at, :ship_code,
     :shipping_receipt, billing_info: [:email], shipping_info_attributes: [:shipping_way, :id]]
  end

  def order_search_attrs
    [:s, :search, :aasm_state, :payment, :billing_info_country_code, :platform, :work_states, :created_at, :coupon, :flags]
  end

  def home_slide_attrs
    [:id, :slide, :is_enabled, :title, :link, :template, :title2, :title3,
     :content1, :content2, :content3, :background, :priority, :set,
     translations_attributes: [:id, :slide, :locale]] + HomeSlide.globalize_attribute_names
  end

  def note_attrs
    [:message]
  end

  def announcement_attrs
    [:message, :starts_at, :ends_at, :default] + Announcement.globalize_attribute_names
  end

  def notification_attrs
    [:message, :delivery_at, :deep_link, filter: [:device_type_in, country_code_in: []]]
  end

  def layer_attrs
    [:layer_type, :position, :position_x, :position_y, :scale_x, :scale_y,
     :orientation, :color, :transparent, :font_name, :font_text, :text_spacing_x,
     :text_spacing_y, :text_alignment, :material_name, :image_aid,
     :filtered_image_aid, :filter, :disabled]
  end

  def mobile_ui_attrs
    [:title, :description, :image, :template, :start_at, :end_at, :priority, :is_enabled, :default]
  end

  def home_link_attrs
    [:id, :href, :position, translations_attributes: [:id, :name, :locale]]
  end

  def email_banner_attrs
    [:name, :file, :starts_at, :ends_at, :is_default]
  end

  def asset_package_category_attrs
    [:name, :available, translations_attributes: [:id, :name, :locale]] + AssetPackageCategory.globalize_attribute_names
  end

  def mask_attrs
    [:material_name, :image]
  end

  def header_link_attrs
    [:id, :parent_id, :href, :position, :link_type, :spec_id, :blank, :dropdown, :row, :auto_generate_product,
     translations_attributes: [:id, :title, :locale],
     tags_attributes: [:id, :title, :style, :_destroy, translations_attributes: [:id, :title, :locale]]]
  end

  def collection_attrs
    [:name, translations_attributes: [:id, :text, :locale]]
  end

  def tag_attrs
    [:name, translations_attributes: [:id, :text, :locale]]
  end

  def recommend_sort_attrs
    [:design_platform, :sort]
  end

  def promotion_attrs
    [:name, :type, :rule, :begins_at, :ends_at, :description, :rule_discount_type,
     :rule_price_tier, :rule_percentage, :rule_threshold_price_tier,
     targets: []]
  end

  def adjustment_attrs
    [:order_id, :adjustable_id, :adjustable_type, :source_id, :source_type, :value, :description, :target, :event]
  end

  def store_attrs
    [:name, :email, :password, :password_confirmation, :contact_emails]
  end

  def reward_attrs
    %i(order_no coupon_code avatar cover)
  end
end
