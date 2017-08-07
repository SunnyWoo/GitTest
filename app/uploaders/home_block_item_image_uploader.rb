class HomeBlockItemImageUploader < DefaultWithMetaUploader
  def collection_2
    on_the_fly_process(resize_to_fill: [460, 310])
  end

  def collection_3
    on_the_fly_process(resize_to_fill: [300, 220])
  end

  def collection_4
    on_the_fly_process(resize_to_fill: [220, 220])
  end

  def thumb
    if model.is_a? HomeBlockItem
      send(model.block.template)
    elsif model.is_a? HomeBlockItem::Translation
      send(model.item.block.template)
    end
  end
end
