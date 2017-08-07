require 'spec_helper'

describe Api::V3::HeaderButtonsController, :api_v3, type: :controller do
  def build_link(key, url, text, children = nil)
    { key: key, url: url, text: text, children: children }.with_indifferent_access
  end

  before { expect(controller).to receive(:doorkeeper_authorize!) }

  context 'list header buttons' do
    Given(:feature_flag_on) { double(FeatureFlag::Feature, enable_for_current_session?: true) }
    Given(:feature_flag_off) { double(FeatureFlag::Feature, enable_for_current_session?: false) }

    context 'editor link' do
      Given(:editor_button) { build_link 'editor', new_work_path, I18n.t('page.btns.create'), editor_children }
      Given(:editor_children) { {} }
      When { expect(controller).to receive(:feature).with(:duncan).and_return(feature_flag_on) }
      When { get :show }
      context 'with editor children' do
        Given!(:product_model) { create(:product_model, customize_platform: { website: 'true' }) }
        Given(:editor_children) do
          name = product_model.category.name
          url = works_path(model_id: product_model.id)
          { name => [{ 'url' => url, 'text' => product_model.name }] }
        end
        Then { response_json['header_buttons'].include?(editor_button) }
      end

      context 'without editor children' do
        Then { response_json['header_buttons'].include?(editor_button) }
      end
    end

    context 'should contain shop_index_path' do
      Given(:shop_button) { build_link 'shop', shop_index_path, I18n.t('page.btns.shop'), shop_children }
      context 'with shop children' do
        Given!(:product_model) { create(:product_model, design_platform: { website: 'true' }) }
        Given(:shop_children) do
          name = product_model.category.name
          url = works_path(model_id: product_model.id)
          { name => [{ 'url' => url, 'text' => product_model.name }] }
        end
        When { get :show }
        Then { response_json['header_buttons'].include?(shop_button) }
      end
      context 'without shop children' do
        Given(:shop_children) { {} }
        When { get :show }
        Then { response_json['header_buttons'].include?(shop_button) }
      end
    end

    context 'should contain app link' do
      Given(:app_button) { build_link 'app', 'http://bit.ly/1nMC8yU', I18n.t('page.btns.app') }
      When { get :show }
      Then { response_json['header_buttons'].include?(app_button) }
    end

    context 'duncan campaign' do
      Given(:duncan_button) { build_link 'duncan', campaign_path(:duncan), 'Duncan Design' }

      context 'when feature :duncan is on' do
        When { expect(controller).to receive(:feature).with(:duncan).and_return(feature_flag_on) }
        When { get :show }
        Then { response_json['header_buttons'].include?(duncan_button) }
      end

      context 'when feature :duncan is off' do
        When { expect(controller).to receive(:feature).with(:duncan).and_return(feature_flag_off) }
        When { get :show }
        Then { response_json['header_buttons'].include?(duncan_button) == false }
      end
    end
  end
end
