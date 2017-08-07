require 'spec_helper'

describe UserMailer do
  let(:user) { create(:user) }

  context '#send_password_reset' do
    it 'when user locale in zh-TW' do
      user.update(locale: 'zh-TW')
      mail = UserMailer.send_password_reset user.id, 'reset_token-xxxxx', nil
      I18n.locale = 'zh-TW'
      expect(mail.subject).to eq('你已要求重設你的 我印 登入密碼')
    end

    it 'when user locale is zh-CN' do
      user.update(locale: 'zh-CN')
      mail = UserMailer.send_password_reset user.id, 'reset_token-xxxxx', nil
      I18n.locale = 'zh-CN'
      expect(mail.subject).to eq('重新设置 噗印 登录密码')
    end

    it 'when user locale is ja' do
      user.update(locale: 'ja')
      mail = UserMailer.send_password_reset user.id, 'reset_token-xxxxx', nil
      I18n.locale = 'ja'
      expect(mail.subject).to eq('コマプリ - パスワードをリセットします')
    end

    it 'when user locale is en' do
      user.update(locale: 'en')
      mail = UserMailer.send_password_reset user.id, 'reset_token-xxxxx', nil
      I18n.locale = 'en'
      expect(mail.subject).to eq('commandp - password reset service')
    end
  end

  context '#send_confirmation' do
    it 'when user locale in zh-TW' do
      user.update(locale: 'zh-TW')
      mail = UserMailer.send_confirmation user.id, 'reset_token-xxxxx', nil
      I18n.locale = 'zh-TW'
      expect(mail.subject).to eq('我印 - 請驗證您的電子郵件地址')
    end

    it 'when user locale is zh-CN' do
      user.update(locale: 'zh-CN')
      mail = UserMailer.send_confirmation user.id, 'reset_token-xxxxx', nil
      I18n.locale = 'zh-CN'
      expect(mail.subject).to eq('噗印 - 请验证你的邮箱地址')
    end

    it 'when user locale is ja' do
      user.update(locale: 'ja')
      mail = UserMailer.send_confirmation user.id, 'reset_token-xxxxx', nil
      I18n.locale = 'ja'
      expect(mail.subject).to eq('コマプリ - メールアドレスの登録確認')
    end

    it 'when user locale is en' do
      user.update(locale: 'en')
      mail = UserMailer.send_confirmation user.id, 'reset_token-xxxxx', nil
      I18n.locale = 'en'
      expect(mail.subject).to eq('commandp - Please confirm your email')
    end
  end

  context '#send_confirmation' do
    it 'when user locale in zh-TW' do
      user.update(locale: 'zh-TW')
      mail = UserMailer.send_welcome user.id
      I18n.locale = 'zh-TW'
      expect(mail.subject).to eq('歡迎你成為 我印 的用戶')
    end

    it 'when user locale is zh-CN' do
      user.update(locale: 'zh-CN')
      mail = UserMailer.send_welcome user.id
      I18n.locale = 'zh-CN'
      expect(mail.subject).to eq('歡迎你成為 噗印 的用戶')
    end

    it 'when user locale is ja' do
      user.update(locale: 'ja')
      mail = UserMailer.send_welcome user.id
      I18n.locale = 'ja'
      expect(mail.subject).to eq('コマプリ - 登録完了のお知らせ')
    end

    it 'when user locale is en' do
      user.update(locale: 'en')
      mail = UserMailer.send_welcome user.id
      I18n.locale = 'en'
      expect(mail.subject).to eq('Welcome to commandp')
    end

    it 'when user email is guest_xxxx@commandp.com' do
      user.update(email: 'guest_xxxx@commandp.com')
      user.confirm!
      mail = UserMailer.send_welcome user.id
      expect(mail.subject).to be_nil
    end
  end
end
