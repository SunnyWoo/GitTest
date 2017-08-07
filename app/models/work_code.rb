# == Schema Information
#
# Table name: work_codes
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  user_type    :string(255)
#  work_type    :string(255)
#  work_id      :integer
#  code         :string(255)
#  product_code :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class WorkCode < ActiveRecord::Base
  include UploadInventory
  belongs_to :work, -> { try(:with_deleted) || all }, polymorphic: true

  validates :code, uniqueness: { scope: [:user_id, :user_type] }, if: :designer?

  def self.generate_code(user_id, user_type)
    return '000' unless user_type == 'Designer'
    loop do
      code = [*'0'..'9', *'A'..'Z'].sample(3).join
      return code unless exists?(code: code, user_id: user_id, user_type: 'Designer')
    end
  end

  def self.create_work_code(work)
    user_id = work.user_id
    user_type = work.user_type
    work_code = new(work: work, user_id: user_id, user_type: user_type, code: generate_code(user_id, user_type))
    work_code.product_code = "#{work.product.product_code}-#{work.user_code}-#{work_code.code}"
    work_code.save!
  end

  def designer?
    user_type == 'Designer'
  end
end
