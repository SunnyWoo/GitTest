class NormalizeLayerTextAlignmentValues < ActiveRecord::Migration
  NORMALIZE_TABLE = {
    '0' => 'Left',
    '1' => 'Center',
    '2' => 'Right'
  }

  def up
    Layer.where('text_alignment IS NOT NULL').find_each do |layer|
      text_alignment = NORMALIZE_TABLE[layer.text_alignment]
      pp(text_alignment: text_alignment)
      layer.update(text_alignment: text_alignment)
    end
  end

  def down
    Layer.where('text_alignment IS NOT NULL').find_each do |layer|
      text_alignment = NORMALIZE_TABLE.rassoc(layer.text_alignment)
      pp(text_alignment: text_alignment)
      layer.update(text_alignment: NORMALIZE_TABLE[layer.text_alignment])
    end
  end

  class Layer < ActiveRecord::Base
  end
end
