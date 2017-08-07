# == Schema Information
#
# Table name: file_gateways
#
#  id           :integer          not null, primary key
#  type         :string(255)
#  factory_id   :integer
#  connect_info :hstore
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe FtpGateway do
  it 'FactoryGirl' do
    expect(build(:ftp_gateway)).to be_valid
  end

  Given(:sftp_obj) { build(:ftp_gateway, enable_sftp: true) }

  context '#upload' do
    context 'call #sftp_upload when enable_sftp' do
      before { expect(sftp_obj).to receive(:sftp_upload).and_return(true) }
      Then { sftp_obj.upload('test.file') }
    end
  end

  context '#sftp_upload' do
    Given(:file) { 'tmp/turtle.jpg' }
    Given(:full_path) { '/ftp/test/turtle.jpg' }
    Given(:serv) { SftpService.new }
    before { expect(SftpService).to receive(:new).and_return(serv) }
    before { expect(serv).to receive(:upload_file).with(file, full_path).and_return(true) }
    Then { sftp_obj.sftp_upload('tmp/turtle.jpg', path: 'ftp/test') }
  end
end
