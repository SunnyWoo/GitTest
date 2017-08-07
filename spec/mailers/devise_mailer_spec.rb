require 'spec_helper'

describe DeviseMailer do
  let(:user) { create(:user) }

  context '#confirmation_instructions' do
    it 'when user locale in zh-TW' do
      user.update(locale: 'zh-TW')
      mail = DeviseMailer.confirmation_instructions user, user.confirmation_token
      I18n.locale = 'zh-TW'
      expect(mail.subject).to eq('我印 - 請驗證您的電子郵件地址')
    end

    it 'when user locale is zh-CN' do
      user.update(locale: 'zh-CN')
      mail = DeviseMailer.confirmation_instructions user, user.confirmation_token
      I18n.locale = 'zh-CN'
      expect(mail.subject).to eq('噗印 - 请验证你的邮箱地址')
    end

    it 'when user locale is ja' do
      user.update(locale: 'ja')
      mail = DeviseMailer.confirmation_instructions user, user.confirmation_token
      I18n.locale = 'ja'
      expect(mail.subject).to eq('コマプリ - メールアドレスの登録確認')
    end

    it 'when user locale is en' do
      user.update(locale: 'en')
      mail = DeviseMailer.confirmation_instructions user, user.confirmation_token
      I18n.locale = 'en'
      expect(mail.subject).to eq('commandp - Please confirm your email')
    end
  end

  context '#reset_password_instructions' do
    it 'when user locale in zh-TW' do
      user.update(locale: 'zh-TW')
      mail = DeviseMailer.reset_password_instructions user, 'reset_token-xxxxx'
      I18n.locale = 'zh-TW'
      expect(mail.subject).to eq('你已要求重設你的 我印 登入密碼')
    end

    it 'when user locale is zh-CN' do
      user.update(locale: 'zh-CN')
      mail = DeviseMailer.reset_password_instructions user, 'reset_token-xxxxx'
      I18n.locale = 'zh-CN'
      expect(mail.subject).to eq('重新设置 噗印 登录密码')
    end

    it 'when user locale is ja' do
      user.update(locale: 'ja')
      mail = DeviseMailer.reset_password_instructions user, 'reset_token-xxxxx'
      I18n.locale = 'ja'
      expect(mail.subject).to eq('コマプリ - パスワードをリセットします')
    end

    it 'when user locale is en' do
      user.update(locale: 'en')
      mail = DeviseMailer.reset_password_instructions user, 'reset_token-xxxxx'
      I18n.locale = 'en'
      expect(mail.subject).to eq('commandp - password reset service')
    end
  end
end
