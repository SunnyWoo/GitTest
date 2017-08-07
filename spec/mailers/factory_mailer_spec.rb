require 'spec_helper'

describe FactoryMailer do
  describe '.file_uploaded' do
    let(:factory_member) { create :factory_member }
    let(:factory) { factory_member.factory }
    let!(:product_model) { create(:product_model, factory_id: factory.id) }
    let(:batch_flow) { create :batch_flow, factory_id: factory_member.factory_id, product_model_ids: [product_model.id] }
    let(:mail) { FactoryMailer.file_uploaded(batch_flow.id, batch_flow.factory_id) }

    it 'renders the headers' do
      expect(mail.subject).to eq("#{factory.name} #{batch_flow.number_with_source} Purchase Notification from Commandp")
      expect(mail.to).to eq([batch_flow.factory.contact_email])
      expect(mail.from).to eq(["no-reply@#{MailerService.domain}"])
    end
  end
end
