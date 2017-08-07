require 'spec_helper'

describe OrderMailer do
  let(:user) { create(:user) }
  let(:order) { create(:order, :priced, :with_stripe, user: user).tap(&:reload) }
  let!(:fee) { create(:fee, name: 'cash_on_delivery') }
  let!(:currency) { create(:currency, name: 'TWD', code: 'TWD', payable: fee, price: 30) }

  before do
    I18n.locale = 'en'
    Fee.find_by(name: 'cash_on_delivery').price_in_currency('TWD')
    create_basic_currencies
    order.order_items.first.itemable.update(cover_image: File.new('spec/photos/test.jpg'))
  end

  context 'receipt' do
    let(:mail) { OrderMailer.receipt(user.id, order.id) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('email.order.receipt.subject'))
      expect(mail.to).to eq([order.billing_info.email])
      expect(mail.from).to eq(["no-reply@#{MailerService.domain}"])
    end

    it 'renders the body' do
      expect(mail.body.encoded.gsub(/=\r\n/, '')).to match(order.order_no)
    end

    it 'when order locale in zh-TW' do
      order.update(locale: 'zh-TW')
      mail = OrderMailer.receipt(user.id, order.id, order.locale)
      expect(mail.subject).to eq('你的我印訂單明細')
    end

    it 'when order locale is zh-CN' do
      order.update(locale: 'zh-CN')
      mail = OrderMailer.receipt(user.id, order.id, order.locale)
      expect(mail.subject).to eq('你的噗印订单明细')
    end

    it 'when order locale is ja' do
      order.update(locale: 'ja')
      mail = OrderMailer.receipt(user.id, order.id, order.locale)
      expect(mail.subject).to eq('【コマプリ】ご注文ありがとうございます。')
    end

    it 'when order locale is en' do
      order.update(locale: 'en')
      mail = OrderMailer.receipt(user.id, order.id, order.locale)
      expect(mail.subject).to eq('Your Receipt')
    end
  end

  context 'download' do
    let(:mail) { OrderMailer.download(user.id, order.id) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('email.order.download.subject'))
      expect(mail.to).to eq([order.billing_info.email])
      expect(mail.from).to eq(["no-reply@#{MailerService.domain}"])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(order.order_no)
    end

    it 'when order locale in zh-TW' do
      order.update(locale: 'zh-TW')
      mail = OrderMailer.download(user.id, order.id, order.locale)
      expect(mail.subject).to eq('專屬於你的手機桌布')
    end

    it 'when order locale is zh-CN' do
      order.update(locale: 'zh-CN')
      mail = OrderMailer.download(user.id, order.id, order.locale)
      expect(mail.subject).to eq('专属于你的手机桌布')
    end

    it 'when order locale is ja' do
      order.update(locale: 'ja')
      mail = OrderMailer.download(user.id, order.id, order.locale)
      expect(mail.subject).to eq('【コマプリ】壁紙設定のご案内')
    end

    it 'when order locale is en' do
      order.update(locale: 'en')
      mail = OrderMailer.download(user.id, order.id, order.locale)
      expect(mail.subject).to eq('Your Wallpaper')
    end
  end

  context 'download, ProductModel with case or cover' do
    before do
      @work = create(:work, :with_cover_image, model: create(:mug_product_model))
    end

    it 'ProductModel not include case or cover' do
      order2 = create(:order, user: user)
      order2.order_items.delete_all
      create(:order_item, itemable: @work, order: order2)
      order2.reload

      mail = OrderMailer.download(user.id, order2.id)

      expect(mail.subject).to be nil
      expect(mail.to).to be nil
      expect(mail.from).to be nil
    end

    it 'ProductModel include case or cover' do
      order2 = create(:order, user: user).tap(&:reload)
      order2.order_items.first.itemable.update(cover_image: File.new('spec/photos/test.jpg'))
      create(:order_item, itemable: @work, order: order2)
      order2.reload

      mail = OrderMailer.download(user.id, order2.id)

      expect(mail.subject).to eq(I18n.t('email.order.download.subject'))
      expect(mail.to).to eq([order2.billing_info.email])
      expect(mail.from).to eq(["no-reply@#{MailerService.domain}"])
      expect(mail.body.encoded).to match(order2.order_no)
    end
  end

  context 'ship' do
    let(:mail) { OrderMailer.ship(user.id, order.id) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('email.order.ship.subject'))
      expect(mail.to).to eq([order.billing_info.email])
      expect(mail.from).to eq(["no-reply@#{MailerService.domain}"])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Thanks for your order!')
    end
  end

  context 'receipt_with_status' do
    before do
      order.payment = 'neweb/atm'
      order.save
    end

    let(:mail) { OrderMailer.receipt_with_status(user.id, order.id) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n.t('email.order.receipt_with_status.subject'))
      expect(mail.to).to eq([order.billing_info.email])
      expect(mail.from).to eq(["no-reply@#{MailerService.domain}"])
    end

    it 'renders the body' do
      expect(mail.body.decoded).to match(
        "Payment Type：#{I18n.t('email.order.share.payment')[order.payment.to_sym]}"
      )
    end

    it 'when order locale in zh-TW' do
      order.update(locale: 'zh-TW')
      mail = OrderMailer.receipt_with_status(user.id, order.id, order.locale)
      expect(mail.subject).to eq('你的我印訂單狀態')
    end

    it 'when order locale is zh-CN' do
      order.update(locale: 'zh-CN')
      mail = OrderMailer.receipt_with_status(user.id, order.id, order.locale)
      expect(mail.subject).to eq('你的噗印订单状态')
    end

    it 'when order locale is ja' do
      order.update(locale: 'ja')
      mail = OrderMailer.receipt_with_status(user.id, order.id, order.locale)
      expect(mail.subject).to eq('【コマプリ】ご注文状況')
    end

    it 'when order locale is en' do
      order.update(locale: 'en')
      mail = OrderMailer.receipt_with_status(user.id, order.id, order.locale)
      expect(mail.subject).to eq('Your commandp Order Status')
    end
  end

  context '#deliver' do
    after(:each) do
      ActionMailer::Base.deliveries.clear
    end

    let(:mail) { OrderMailer.receipt(user.id, order.id) }

    it 'should deliver mail actually' do
      mail.deliver
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    context 'when order is not notifiable' do
      before { Order.any_instance.stub(:notifiable?).and_return(false) }
      it 'should not deliver the mail' do
        mail.deliver
        expect(ActionMailer::Base.deliveries.count).to eq 0
      end
    end
  end
end
