require 'spec_helper'

RSpec.describe 'api/v3/my/asset_packages/index', type: :view do
  let(:package) do
    create(:available_asset_package, category: create(:asset_package_category))
  end

  it 'renders package' do
    assign(:packages, [package])
    render
    expect(JSON.parse(rendered)).to eq(
      'asset_packages' => [{
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
      }],
      'meta' => {
        'asset_packages_count' => 1
      }
    )
  end
end
