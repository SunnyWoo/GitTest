require 'spec_helper'

Temping.create :dummy_qiniu_store do
  with_columns do |t|
    t.string :cover_image
    t.string :print_image
    t.string :order_image
    t.datetime :updated_at
  end
  include QiniuStoreImage
  mount_uploader :cover_image, CoverImageUploader
  mount_uploader :print_image, DefaultUploader
  mount_uploader :order_image, DefaultUploader
end

describe QiniuStoreImage do
  context '#qiniu_url' do
    Given(:dummy) { DummyQiniuStore.create }
    before do
      stub_request(:get, 'http://pica.nipic.com/2007-11-09/200711912453162_2.jpg').to_return(status: 200, body: "image", headers: {})
      allow(dummy.cover_image).to receive(:url).and_return('http://pica.nipic.com/2007-11-09/200711912453162_2.jpg')
      allow(dummy.print_image).to receive(:url).and_return('http://pica.nipic.com/2007-11-09/200711912453162_2.jpg')
      allow(dummy.order_image).to receive(:url).and_return('http://pica.nipic.com/2007-11-09/200711912453162_2.jpg')
    end

    Then { dummy.qiniu_cover_image_url.match('uploads/delivery/dummy_qiniu_store/cover_image').present? }
    Then { dummy.qiniu_cover_image_shop_url.match('uploads/delivery/dummy_qiniu_store/cover_image').present? }
    And { dummy.qiniu_print_image_url.match('uploads/delivery/dummy_qiniu_store/print_image').present? }
    And { dummy.qiniu_order_image_url.match('uploads/delivery/dummy_qiniu_store/order_image').present? }
  end

  context 'when CarrierWave::DownloadError' do
    Given(:dummy) { DummyQiniuStore.create }
    before do
      stub_request(:get, 'http://pica.nipic.com/2007-11-09/200711912453162_2.jpg').to_return(status: 200, body: "image", headers: {})
      allow(dummy.cover_image).to receive(:url).and_return('http://pica.nipic.com/2007-11-09/200711912453162_2.jpg')
    end
    before { allow(dummy).to receive(:download!).and_raise(CarrierWave::DownloadError) }
    Then { dummy.qiniu_cover_image_url.nil? }
  end
end
