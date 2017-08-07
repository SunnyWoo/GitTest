class PrintPermittedParams < Struct.new(:params)
  [:factory, :ftp_gateway, :note, :shelf].each do |model_name|
    define_method model_name do
      params.require(model_name).permit(send("#{model_name}_attrs"))
    end
  end

  def factory_attrs
    [:code, :name, :location, ftp_gateway_attributes: ftp_gateway_attrs]
  end

  def ftp_gateway_attrs
    [:url, :port, :username, :password]
  end

  def note_attrs
    [:message]
  end

  def shelf_attrs
    %i(serial section name)
  end
end
