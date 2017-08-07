module SharedLayerMethods
  def commandp_resource_material
    return unless Layer::COMMANDP_RESOURCE_TYPES.include? layer_type
    @commandp_resource_material ||= CommandP::Resources.send(layer_type.pluralize)[material_name] || fallback_to_use_local_material
  end

  def commandp_resources_material_image_path
    return unless commandp_resource_material
    commandp_resource_material.local_raw_file
  end

  def commandp_resources_material_path
    return unless commandp_resource_material
    commandp_resource_material.local_file
  end

  def fallback_to_use_local_material
    file = "#{Settings.graphic_library_path}#{layer_type}/#{material_name}@2x.png"
    OpenStruct.new(local_raw_file: file, local_file: file) if File.exists?(file)
  end

  def printable?
    case layer_type
    when 'photo'
      filtered_image.present?
    else
      true
    end
  end
end
