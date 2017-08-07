# == Schema Information
#
# Table name: recommend_sorts
#
#  id              :integer          not null, primary key
#  design_platform :string(255)
#  sort            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class RecommendSort < ActiveRecord::Base
  validates :sort, :design_platform, presence: true
  validates :sort, inclusion: %w(new popular price_asc price_desc random)
end
