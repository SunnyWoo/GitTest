shared_examples_for 'acts_as_taggable' do
  let(:tag) { create :tag }
  let(:model) { described_class }
  let(:obj_name) { model.to_s.underscore.to_sym }
  let(:obj) { create(obj_name) }

  it { is_expected.to have_many(:tags) }
  it { is_expected.to have_many(:taggings) }

  it 'tag_ids change' do
    obj.tag_ids = [tag.id]
    expect(obj.tag_ids).to eq([tag.id])
    expect(obj.tag_ids_changed?).to eq(true)
  end
end
