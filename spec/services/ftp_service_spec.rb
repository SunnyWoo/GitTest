require 'spec_helper'

describe FtpService do

  context 'init' do
    it "reutnr status 211" do
      ftp = FtpService.new
      allow(ftp).to receive(:status) { 211 }
      expect(ftp.status).to eq(211)
    end
  end

  context 'upload' do
    it 'success' do
      ftp = FtpService.new
      allow(ftp).to receive(:login) { true }
      ftp.login
      ftp.chdir
      allow(ftp).to receive(:upload_file) { true }
      file_name = 'public/logo.png'
      expect(ftp.upload_file(file_name)).to be true
    end

    it 'No such file or directory' do
      ftp = FtpService.new
      allow(ftp).to receive(:login) { true }
      ftp.login
      ftp.chdir
      file_name = 'public/xxxx.png'
      expect(ftp.upload_file(file_name)).to match('No such file or directory')
    end
  end

end