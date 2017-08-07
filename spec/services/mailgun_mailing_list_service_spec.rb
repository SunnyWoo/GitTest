require 'spec_helper'

describe MailgunMailingListService do
  context '#execute' do
    it 'when Region is chian' do
      stub_env('REGION', 'china')
      mailing = MailgunMailingListService.new('test@commandp.com')
      expect(mailing.execute).to be_nil
    end

    it 'when email is guest_xxx@commandp.com', :vcr do
      mailing = MailgunMailingListService.new('guest_xxx@commandp.com')
      expect(mailing.execute).to be_nil
    end

    it 'when Region is global', :vcr do
      mailing = MailgunMailingListService.new('test@commandp.com')
      expect(mailing.execute).to be true
    end
  end
end
