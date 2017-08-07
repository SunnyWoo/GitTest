require 'spec_helper'

describe 'PlainWorkForm' do
  context 'initialize on new' do
    it 'has blank fields' do
      form = PlainWorkForm.new
      expect(form.work).to be_nil
      expect(form.name).to be_nil
      expect(form.description).to be_nil
      expect(form.model_id).to be_nil
      expect(form.cover_image).to be_nil
      expect(form.work_type).to be_nil
      expect(form.featured).to be_nil
      expect(form.user_id).to be_nil
    end
  end

  context 'assign values and save on new' do
    it 'creates work correctly' do
      product = create(:product_model)
      user = create(:designer_user)
      form = PlainWorkForm.new(name: 'Roman',
                               description: '第五の地平線',
                               model_id: product.id,
                               cover_image: nil,
                               work_type: 'is_private',
                               featured: '1',
                               user_id: user.id)
      form.save

      expect(form.work).to be_valid
      expect(form.work).to be_persisted
      expect(form.work.user).to eq(user)
      expect(form.work.name).to eq('Roman')
      expect(form.work.description).to eq('第五の地平線')
      expect(form.work.product).to eq(product)
      expect(form.work.cover_image).to be_blank
      expect(form.work.work_type).to eq('is_private')
      expect(form.work.feature).to be(true)
    end
  end

  context 'initialize on edit' do
    it 'has blank fields' do
      work = create(:work)
      form = PlainWorkForm.new(work: work)
      expect(form.work).to eq(work)
      expect(form.name).to eq(work.name)
      expect(form.description).to eq(work.description)
      expect(form.model_id).to eq(work.product.id)
      expect(form.cover_image).to eq(work.cover_image)
      expect(form.work_type).to eq(work.work_type)
      expect(form.featured).to be(work.featured)
      expect(form.user_id).to eq(work.user.id)
    end
  end

  context 'assign values and save on edit' do
    it 'updates work correctly' do
      work = create(:work)
      product = create(:product_model)
      form = PlainWorkForm.new(work: work)
      form.update_attributes(name: '北斗の拳 世紀末救世主伝説', model_id: product.id)
      expect(form.work.name).to eq('北斗の拳 世紀末救世主伝説')
      expect(form.work.product).to eq(product)
    end
  end
end
