# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string(255)
#

require 'rails_helper'

RSpec.describe Tag, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:text_en) }

  it 'validates text should be unique per every locales' do
    I18n.locale = 'en'
    Tag.create(name: 'Black', text_zh_tw: '黑', text_en: 'Black')
    expect(Tag.new(name: 'Black', text_zh_tw: '黑', text_en: 'Black')).to be_invalid
    expect(Tag.new(name: 'NewBlack', text_zh_tw: '黑色', text_en: 'Black')).to be_valid
    expect(Tag.new(name: 'AnotherBlack', text_zh_tw: '黑色', text_en: 'Another Black')).to be_valid
  end

  it 'validates name should be letter, number, _, -' do
    expect(Tag.new(name: 'Black黑', text_zh_tw: '黑', text_en: 'Black')).to be_invalid
    expect(Tag.new(name: 'Bla ck黑', text_zh_tw: '黑', text_en: 'Black')).to be_invalid
    expect(Tag.new(name: 'Black%', text_zh_tw: '黑', text_en: 'Black')).to be_invalid
    expect(Tag.new(name: 'Black_', text_zh_tw: '黑色', text_en: 'Black')).to be_valid
    expect(Tag.new(name: 'Black_-', text_zh_tw: '黑色', text_en: 'Black')).to be_valid
    expect(Tag.new(name: 'Black1_-', text_zh_tw: '黑色', text_en: 'Black')).to be_valid
  end
end
