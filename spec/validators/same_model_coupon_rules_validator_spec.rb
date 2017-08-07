require 'spec_helper'

class TestCouponRulesModel
  include ActiveModel::Validations
  validates_with SameModelCouponRulesValidator

  attr_reader :coupon_rules

  def initialize(coupon_rules)
    @coupon_rules = coupon_rules
  end
end

describe SameModelCouponRulesValidator do
  Given(:validator) { SameModelCouponRulesValidator.new }

  context '#validate' do
    Given(:test_model) { TestCouponRulesModel.new([coupon_rule, coupon_rule2]) }
    context 'valid: model1 + model2' do
      Given(:coupon_rule) { create(:coupon_rule, condition: 'include_product_models', product_model_ids: [1]) }
      Given(:coupon_rule2) { create(:coupon_rule, condition: 'include_product_models', product_model_ids: [2]) }
      Then { test_model.valid? == true }
    end

    context 'invalid: model + designer' do
      Given(:coupon_rule) { create(:coupon_rule, condition: 'include_product_models', product_model_ids: [1]) }
      Given(:coupon_rule2) { create(:coupon_rule, condition: 'include_designers', designer_ids: [2]) }
      Then { test_model.valid? == false }
    end

    context 'invalid: rules contains duplicate model_id' do
      Given(:coupon_rule) { create(:coupon_rule, condition: 'include_product_models', product_model_ids: [1, 3]) }
      Given(:coupon_rule2) { create(:coupon_rule, condition: 'include_product_models', product_model_ids: [1, 2]) }
      Then { test_model.valid? == false }
    end
    context 'invalid: rules contains duplicate designer_id and model_id' do
      Given(:coupon_rule) { create(:coupon_rule, condition: 'include_designers_models', designer_ids: [1, 3], product_model_ids: [1, 3, 4]) }
      Given(:coupon_rule2) { create(:coupon_rule, condition: 'include_designers_models', designer_ids: [1, 2], product_model_ids: [1]) }
      Then { test_model.valid? == false }
    end

    context 'valid: rules contains duplicate model_id but with different designer_id' do
      Given(:coupon_rule) { create(:coupon_rule, condition: 'include_designers_models', designer_ids: [3, 5], product_model_ids: [1, 3, 4]) }
      Given(:coupon_rule2) { create(:coupon_rule, condition: 'include_designers_models', designer_ids: [1, 2], product_model_ids: [1]) }
      Then { test_model.valid? == true }
    end
  end

  context '#same_in_array' do
    Then { validator.same_in_array([[1], [2]]) == [] }
    And { validator.same_in_array([[1], [1, 2]]) == [1] }
  end

  context '#designers_and_models_in_coupon_rules' do
    context 'condition: include_designers' do
      Given(:coupon_rule) { double(:coupon_rule, condition: 'include_designers', designer_ids: [2, 3, 4]) }
      Given(:coupon_rule2) { double(:coupon_rule, condition: 'include_designers', designer_ids: [1, 2]) }
      Given(:test_model) { TestCouponRulesModel.new([coupon_rule, coupon_rule2]) }
      Then { validator.designers_and_models_in_coupon_rules(test_model) == [[], [[2, 3, 4], [1, 2]]] }
    end

    context 'condition: include_works' do
      Given(:gid1) { 'gid://command-p/Work/1' }
      Given(:gid2) { 'gid://command-p/Work/2' }
      before do
        allow(GlobalID::Locator).to receive(:locate).with(gid1).and_return double(:work, model_id: 1)
        allow(GlobalID::Locator).to receive(:locate).with(gid2).and_return double(:work, model_id: 2)
      end
      Given(:coupon_rule) { double(:coupon_rule, condition: 'include_works', work_gids: [gid1]) }
      Given(:coupon_rule2) { double(:coupon_rule, condition: 'include_works', work_gids: [gid2]) }
      Given(:test_model) { TestCouponRulesModel.new([coupon_rule, coupon_rule2]) }
      Then { validator.designers_and_models_in_coupon_rules(test_model) == [[[1], [2]], []] }
    end
  end
end
