# == Schema Information
#
# Table name: work_sets
#
#  id                  :integer          not null, primary key
#  designer_id         :integer
#  model_id            :integer
#  work_ids            :integer          default([]), is an Array
#  created_at          :datetime
#  updated_at          :datetime
#  zip_filename        :string(255)
#  zip_entry_filenames :string(255)      default([]), is an Array
#  designer_type       :string(255)
#

class WorkSetBefore < WorkSet
  attr_accessor :work_type

  def create_works_by_zip_entries
    self.works = zip_entries.map do |entry|
      name = entry[:name]
      file = entry[:file]
      work = Work.create(name: name,
                         user: designer,
                         product: product,
                         work_type: work_type,
                         feature: false,
                         cover_image: file,
                         print_image: file)
      work.build_layer
      work.finish!
      work
    end
  end
end
