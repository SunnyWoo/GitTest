require 'spec_helper'

RSpec.describe Region do
  context '.region' do
    context 'When ENV REGION: china' do
      When { stub_env('REGION', 'china') }
      Then { Region.region == 'china' }
    end

    context 'When ENV REGION: global' do
      When { stub_env('REGION', 'global') }
      Then { Region.region == 'global' }
    end

    context 'ENV REGION default' do
      When { stub_env('REGION', nil) }
      Then { Region.region == 'global' }
    end
  end

  context '.china?' do
    context 'When Region.region is china' do
      When { expect(Region).to receive(:region).and_return('china') }
      Then { Region.china? == true }
      Then { Region.default_locale == 'zh-CN' }
    end

    context 'Otherwise' do
      When { expect(Region).to receive(:region).and_return('global') }
      Then { Region.china? == false }
      Then { Region.default_locale == 'en' }
    end
  end

  context '.global?' do
    context 'When Region.region is china' do
      When { expect(Region).to receive(:region).and_return('china') }
      Then { Region.global? == false }
      Then { Region.default_locale == 'zh-CN' }
    end

    context 'When Region.region is global' do
      When { expect(Region).to receive(:region).and_return('global') }
      Then { Region.global? == true }
      Then { Region.default_locale == 'en' }
    end
  end
end
