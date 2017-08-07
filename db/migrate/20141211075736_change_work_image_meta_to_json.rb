class ChangeWorkImageMetaToJson < ActiveRecord::Migration
  def change
    Work.find_each do |work|
      if work.image_meta.blank?
        work.update(image_meta: '{}')
      else
        open_struct = YAML.load(work.image_meta)
        work.update(image_meta: open_struct.to_h.to_json)
      end
    end

    change_column :works, :image_meta, 'json USING image_meta::json', default: {}, null: false
  end

  class Work < ActiveRecord::Base
  end
end
