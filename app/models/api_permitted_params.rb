ApiPermittedParams = Struct.new(:params, :user) do
  def work
    params.permit(work_attrs)
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

  # Workaround, since iOS still sent first_name as name probably, remove it after iOS fixed that issue
  def order
    params.permit(order_attrs).tap do |ans|
      si = Hash(params[:shipping_info])
      bi = Hash(params[:billing_info])
      ans[:shipping_info][:name] = si[:first_name] if si[:name].blank? && si[:first_name].present?
      ans[:billing_info][:name] = bi[:first_name] if bi[:name].blank? && bi[:first_name].present?
    end
  end

  def order_pay
    params.permit(*order_pay_attrs)
  end

  def order_pay_attrs
    [:payment, :payment_method, :payment_id]
  end

  def order_attrs
    [:message, :currency, :coupon, :uuid, :payment, :payment_method,
     billing_info: billing_profile_attrs,
     shipping_info: billing_profile_attrs,
     order_items: [:work_id, :work_uuid, :work_gid, :quantity],
     order_info: order_info_attr]
  end

  # 為了新的 campaign 多回傳 訂單資訊
  def order_info_attr
    [:memo, models:[], images: []]
  end

  def billing_profile_attrs
    [:name, :phone, :address, :city, :state, :zip_code, :country, :country_code, :shipping_way, :province, :email, :dist, :dist_code]
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
    [:token, :os_version, :device_type, :country_code, :timezone, :getui_client_id, :idfa]
  end
end
