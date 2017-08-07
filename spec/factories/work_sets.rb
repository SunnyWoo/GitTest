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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :work_set do
    designer
  end
end
