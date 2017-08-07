# == Schema Information
#
# Table name: layers
#
#  id                         :integer          not null, primary key
#  work_id                    :integer
#  orientation                :float            default(0.0)
#  scale_x                    :float            default(1.0)
#  scale_y                    :float            default(1.0)
#  color                      :string(255)
#  transparent                :float            default(1.0)
#  font_name                  :string(255)
#  font_text                  :text
#  image                      :string(255)
#  material_name              :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  layer_type                 :integer
#  layer_no                   :string(255)
#  position_x                 :float            default(0.0)
#  position_y                 :float            default(0.0)
#  text_spacing_x             :integer
#  text_spacing_y             :integer
#  text_alignment             :string(255)
#  filter_type                :integer
#  position                   :integer
#  filter                     :string(255)      default("0")
#  filtered_image             :string(255)
#  uuid                       :string(255)
#  image_meta                 :text
#  disabled                   :boolean          default(FALSE), not null
#  attached_image_id          :integer
#  attached_filtered_image_id :integer
#  mask_id                    :integer
#

require 'spec_helper'

describe Layer do
  it { is_expected.to be_kind_of(HasUniqueUUID) }

  it 'FactoryGirl' do
    expect(build(:layer)).to be_valid
  end

  it { should belong_to(:work) }
  it { should validate_presence_of(:position) }
  it { should validate_presence_of(:layer_type) }
  it { should_not allow_value(1.0 / 0.0).for(:scale_x) }
  it { should_not allow_value(1.0 / 0.0).for(:scale_y) }
  it { should_not allow_value(1.0 / 0.0).for(:position_x) }
  it { should_not allow_value(1.0 / 0.0).for(:position_y) }

  context 'paper_trail' do
    it 'version check' do
      with_versioning do
        layer = create :layer
        first_version_size = layer.versions.size
        expect(first_version_size).not_to eq 0
        layer.update_attribute(:color, 'green')
        expect(layer.versions.size).to be > first_version_size
      end
    end
  end

  describe '#font_path' do
    let(:layer) { create(:layer, font_name: 'Anton', layer_type: 'text') }

    it 'returns correct path', :vcr do
      expect(layer.font_path).to eq(CommandP::Resources.fonts['Anton'].local_file)
    end

    it 'returns Heiti TC if font_name not found', :vcr do
      layer.update_attribute(:font_name, 'blahblahblah')
      expect(layer.reload.font_path).to eq(CommandP::Resources.fonts['Heiti TC'].local_file)
    end

    it 'does not allow blank font path' do
      expect(build(:layer, font_name: nil, layer_type: 'text')).to be_invalid
      expect(build(:layer, font_name: nil)).to be_valid
    end
  end

  describe 'validates name of graphic' do
    it 'in library list', :vcr do
      expect(build(:layer, layer_type: 'texture', material_name: 'blah')).not_to be_valid
    end
  end

  describe '#text_alignment' do
    it 'returns correct align value' do
      expect(build(:layer, text_alignment: '0').text_alignment).to eq('Left')
      expect(build(:layer, text_alignment: '1').text_alignment).to eq('Center')
      expect(build(:layer, text_alignment: '2').text_alignment).to eq('Right')
      expect(build(:layer, text_alignment: 'Left').text_alignment).to eq('Left')
      expect(build(:layer, text_alignment: 'Center').text_alignment).to eq('Center')
      expect(build(:layer, text_alignment: 'Right').text_alignment).to eq('Right')
    end

    it 'sets to left align if value is not allowed' do
      expect(build(:layer, text_alignment: '0').text_alignment).to eq('Left')
      expect(build(:layer, text_alignment: '4').text_alignment).to eq('Left')
    end
  end

  describe '#archived_attributes' do
    it 'returns attributes that can be used to build archived layer' do
      layer = create(:layer)
      expect(layer.archived_attributes).to eq(
        layer_type: layer.layer_type,
        orientation: layer.orientation,
        scale_x: layer.scale_x,
        scale_y: layer.scale_y,
        color: layer.color,
        transparent: layer.transparent,
        font_name: layer.font_name,
        font_text: layer.font_text,
        image: layer.image.file,
        filter: layer.filter,
        filtered_image: layer.filtered_image.file,
        material_name: layer.material_name,
        position_x: layer.position_x,
        position_y: layer.position_y,
        text_spacing_x: layer.text_spacing_x,
        text_spacing_y: layer.text_spacing_y,
        text_alignment: layer.text_alignment,
        position: layer.position,
        masked_layers_attributes: []
      )
    end
  end

  describe 'svg layers' do
    let(:svg) do
      tempfile = File.new(Rails.root + 'spec/fixtures/sample.svg')
      ActionDispatch::Http::UploadedFile.new(filename: 'sample.svg',
                                             type: 'image/svg+xml',
                                             tempfile: tempfile)
    end

    let(:jpg) do
      tempfile = File.new(Rails.root + 'spec/fixtures/great-design.jpg')
      ActionDispatch::Http::UploadedFile.new(filename: 'great-design.jpg',
                                             type: 'image/jpeg',
                                             tempfile: tempfile)
    end

    it 'validates svg should be uploaded' do
      expect(build(:layer, layer_type: 'varnishing', filtered_image: svg)).to be_valid
      expect(build(:layer, layer_type: 'varnishing', filtered_image: nil)).to be_invalid
      expect(build(:layer, layer_type: 'varnishing', filtered_image: jpg)).to be_invalid
      expect(build(:layer, layer_type: 'bronzing', filtered_image: svg)).to be_valid
      expect(build(:layer, layer_type: 'bronzing', filtered_image: nil)).to be_invalid
      expect(build(:layer, layer_type: 'bronzing', filtered_image: jpg)).to be_invalid
    end

    it 'validates material svg should be existed' do
      expect(build(:layer, layer_type: 'varnishing_typography', material_name: 'cp_typography_44')).to be_valid
      expect(build(:layer, layer_type: 'varnishing_typography', material_name: nil)).to be_invalid
      expect(build(:layer, layer_type: 'varnishing_typography', material_name: 'non_exist')).to be_invalid
      expect(build(:layer, layer_type: 'bronzing_typography', material_name: 'cp_typography_44')).to be_valid
      expect(build(:layer, layer_type: 'bronzing_typography', material_name: nil)).to be_invalid
      expect(build(:layer, layer_type: 'bronzing_typography', material_name: 'non_exist')).to be_invalid
    end
  end

  describe 'asset layers' do
    let(:asset) { create(:asset) }

    it 'validates material name should be existed' do
      expect(build(:layer, layer_type: 'sticker_asset', material_name: asset.uuid)).to be_valid
      expect(build(:layer, layer_type: 'sticker_asset', material_name: nil)).to be_invalid
      expect(build(:layer, layer_type: 'sticker_asset', material_name: 'non_exist')).to be_invalid
      expect(build(:layer, layer_type: 'coating_asset', material_name: asset.uuid)).to be_valid
      expect(build(:layer, layer_type: 'coating_asset', material_name: nil)).to be_invalid
      expect(build(:layer, layer_type: 'coating_asset', material_name: 'non_exist')).to be_invalid
      expect(build(:layer, layer_type: 'foiling_asset', material_name: asset.uuid)).to be_valid
      expect(build(:layer, layer_type: 'foiling_asset', material_name: nil)).to be_invalid
      expect(build(:layer, layer_type: 'foiling_asset', material_name: 'non_exist')).to be_invalid
    end
  end

  describe '#image' do
    Given(:layer) { build(:layer) }

    context 'uploads to layer directly' do
      Then { layer.image.model == layer }
    end

    it { should have_attachment(:image) }
  end

  describe '#filtered_image' do
    Given(:layer) { build(:layer) }

    context 'uploads to layer directly' do
      Then { layer.filtered_image.model == layer }
    end

    it { should have_attachment(:filtered_image) }
  end

  it_behaves_like 'commandp_resource_material'
end
