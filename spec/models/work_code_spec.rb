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

require 'rails_helper'

RSpec.describe WorkCode, type: :model do
  it { should belong_to(:work) }

  context 'validate_uniqueness_of code' do
    context ' when designer' do
      Given!(:code) { create :work_code, user_id: 1, user_type: 'Designer', code: 'AAAA' }
      Given(:code2) { WorkCode.new(user_id: 1, user_type: 'Designer', code: 'AAAA') }
      Then { code2.valid? == false }
    end

    context ' when User' do
      Given!(:code) { create :work_code, user_id: 1, user_type: 'User', code: 'BBBB' }
      Given(:code2) { WorkCode.new(user_id: 1, user_type: 'User', code: 'BBBB') }
      Then { code2.valid? == true }
    end
  end

  it 'FactoryGirl' do
    expect(create(:work_code)).to be_valid
  end

  context '#generate_code' do
    context 'user_type id User' do
      Given(:code) { WorkCode.generate_code(1, 'User') }
      Then { code == '000' }
    end

    context 'user_type id Designer' do
      Given(:code) { WorkCode.generate_code(1, 'Designer') }
      Then { code != '000' }
      And { code.size == 3 }
    end
  end

  context '#create_work_code' do
    context 'when Designer' do
      Given(:designer) { create :designer, code: 'ABCD' }
      Given(:work) { create :work, user: designer }
      When { WorkCode.create_work_code(work) }
      Given(:work_code) { WorkCode.last }
      Then { work_code.work == work }
      And { work_code.code != '000' }
      And { work_code.product_code == "#{work.product.product_code}-ABCD-#{work_code.code}" }
    end

    context 'when user' do
      Given(:user) { create :user }
      Given(:work) { create :work }
      When { WorkCode.create_work_code(work) }
      Given(:work_code) { WorkCode.last }
      Then { work_code.work == work }
      And { work_code.product_code == "#{work.product.product_code}-0000-000" }
    end
  end

  context 'included UploadInventory' do
    WorkCode.const_get(:UploadInventory) == UploadInventory
  end
end
