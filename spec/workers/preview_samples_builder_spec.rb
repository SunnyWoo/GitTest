require 'spec_helper'

describe PreviewSamplesBuilder do
  it 'does nothing if updated_at is not matched' do
    composer = create(:preview_composer)
    expect_any_instance_of(PreviewComposer).not_to receive(:sample_works)
    PreviewSamplesBuilder.new.perform(composer.id, 1)
  end

  it 'enqueues PreviewSampleBuilder with sample works' do
    composer = create(:preview_composer)
    allow_any_instance_of(PreviewComposer).to receive(:sample_works).and_return(
      [double(to_gid_param: 1), double(to_gid_param: 2), double(to_gid_param: 3)]
    )
    expect(PreviewSampleBuilder).to receive(:perform_async).with(composer.id, 1, composer.updated_at.to_s)
    expect(PreviewSampleBuilder).to receive(:perform_async).with(composer.id, 2, composer.updated_at.to_s)
    expect(PreviewSampleBuilder).to receive(:perform_async).with(composer.id, 3, composer.updated_at.to_s)
    PreviewSamplesBuilder.new.perform(composer.id, composer.updated_at.to_s)
  end
end
