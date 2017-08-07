require 'spec_helper'

describe SftpService do
  Given(:sftp) { SftpService.new }
  Given(:sess) { double(Net::SFTP::Session) }
  before { allow(Net::SFTP).to receive(:start).and_return(sess) }

  context '#mkdir_p' do
    before do
      expect(sess).to receive(:mkdir!).with('/abc')
      expect(sess).to receive(:mkdir!).with('/abc/bde')
    end
    Then { sftp.mkdir_p('/abc/bde') }
  end

  context '#upload_file' do
    before do
      expect(sftp).to receive(:mkdir_p).with('/ftp/test/testurtle')
      expect(sess).to receive(:upload!).with('spec/fixtures/test.jpg', '/ftp/test/testurtle/test.jpg')
    end

    Then { sftp.upload_file('spec/fixtures/test.jpg', '/ftp/test/testurtle/test.jpg') }
  end
end