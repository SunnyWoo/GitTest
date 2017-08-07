require 'spec_helper'

describe MissingLocalesBuilder do
  context '#build_missing_locale_set' do
    context 'with home_slide for example' do
      it 'creates missing locales for home_slide without any translations' do
        home_slide = create(:home_slide)
        expect(home_slide.translations.size).to eq 1
        home_slide.build_missing_locale_set
        expect(home_slide.translations.size).to eq I18n.available_locales.count
      end

      it 'creates missing locales for home_slide with some translations' do
        home_slide = create(:home_slide)
        home_slide.translations.create(locale: 'ja')
        expect(home_slide.translations.size).to eq 2
        home_slide.build_missing_locale_set
        expect(home_slide.translations.size).to eq I18n.available_locales.count
      end
    end
  end
end
