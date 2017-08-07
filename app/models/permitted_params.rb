class PermittedParams < Struct.new(:params, :current_user)
  [:user, :newsletter_subscription].each do |model_name|
    define_method model_name do
      params.require(model_name).permit(send("#{model_name}_attrs"))
    end
  end

  def user_attrs
    [:name, :location, :gender, :email]
  end

  def work_attrs
    [:uuid, :name, :description, :model, :spec, :cover_image,
     :work_type, layers_attributes: layer_attrs]
  end

  def layer
    params.permit(layer_attrs)
  end

  def layer_attrs
    [:id, :uuid, :position_x, :position_y, :orientation, :scale_x, :scale_y,
     :color, :transparent, :font_name, :font_text, :image, :filtered_image,
     :name, :layer_type, :text_alignment, :text_spacing_x, :text_spacing_y,
     :position, :filter, :_destroy, :material_name]
  end

  def order
    params.permit(order_attrs)
  end

  def order_pay
    params.permit(*order_pay_attrs)
  end

  def order_pay_attrs
    [:payment, :payment_method, :payment_id]
  end

  def order_attrs
    [:currency, :coupon, :uuid, :payment, :payment_method, billing_info: billing_profile_attrs,
    shipping_info: billing_profile_attrs, order_items: [:work_id, :work_uuid, :quantity]]
  end

  def billing_profile_attrs
    [:name, :phone, :address, :city, :state, :zip_code, :country, :country_code, :shipping_way, :email]
  end

  def update_order
    params.permit(update_order_attrs)
  end

  def update_order_attrs
    [:name, :address, :phone]
  end

  def device
    params.permit(*device_attrs)
  end

  def device_attrs
    [:token, :os_version, :device_type]
  end

  def newsletter_subscription_attrs
    [:email]
  end
end
