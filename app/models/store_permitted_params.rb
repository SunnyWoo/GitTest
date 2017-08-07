StorePermittedParams = Struct.new(:params) do
  [:store, :product_template, :standardized_work].each do |model_name|
    define_method model_name do
      params.require(model_name).permit(send("#{model_name}_attrs"))
    end
  end

  def store_attrs
    [:password, :password_confirmation, :avatar, :title, :description, :name, :slug, :logo]
  end

  def product_template_attrs
    [
      :id, :name, :placeholder_image, :template_image, :template_type, :product_model_id,
      :price_tier_id, :aasm_state, :special_price_tier_id, :description, settings: ProductTemplate::TEXT_SETTING_KEYS
    ]
  end

  def standardized_work_attrs
    [
      :name, :feature, :print_image, :price_tier_id, :model_id, :build_previews, :is_build_print_image, :content,
      previews_attributes: [:id, :key, :image, :position, :_destroy],
      output_files_attributes: [:id, :key, :file, :_destroy]
    ]
  end
end
