# == Schema Information
#
# Table name: preview_samples
#
#  id                  :integer          not null, primary key
#  preview_composer_id :integer
#  work_id             :integer
#  result              :string(255)
#  image_meta          :text
#  created_at          :datetime
#  updated_at          :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :preview_sample do
    preview_composer
    work
  end
end
