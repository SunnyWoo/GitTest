require 'spec_helper'

RSpec.describe 'api/v3/asset_package_categories/index', :caching, type: :view do
  let(:category) do
    create(:asset_package_category, packages: [create(:available_asset_package)])
  end

  it 'renders category' do
    assign(:categories, [category])
    render
    expect(JSON.parse(rendered)).to eq(
      'asset_package_categories' => [{
        'id' => category.id,
        'name' => category.name,
        'available' => category.available,
        'packages_count' => category.packages_count,
        'downloads_count' => category.downloads_count,
        'name_translations' => view.full_translations(category.name_translations),
        'packages' => category.packages.map do |package|
          {
            'id' => package.id,
            'name' => package.name,
            'name_translations' => view.full_translations(package.name_translations),
            'description' => package.description,
            'description_translations' => view.full_translations(package.description_translations),
            'available' => package.available,
            'designer_id' => package.designer_id,
            'category_id' => package.category_id,
            'begin_at' => package.begin_at.strftime('%Y-%m-%d'),
            'end_at' => package.end_at.strftime('%Y-%m-%d'),
            'countries' => package.countries,
            'position' => package.position,
            'downloads_count' => package.downloads_count,
            'icon' => package.icon.url,
            'category_name' => package.category_name,
            'designer' => {
              'id' => package.designer.id,
              'display_name' => package.designer.display_name
            }
          }
        end
      }]
    )
  end
end
