require 'spec_helper'

describe EmailAuthentication do
  context '#user' do
    context 'when creates' do
      it 'returns user if success' do
        auth = EmailAuthentication.new(email: 'test@commandp.com',
                                       password: 'commandp',
                                       password_confirmation: 'commandp'
                                      )
        expect(auth.user).to be_kind_of User
        expect(User.count).to eq 1
      end

      it 'raises ActiveRecord::RecordInvalid if email has been used' do
        create(:user, email: 'test@commandp.com', password: 'commandp', password_confirmation: 'commandp')
        auth = EmailAuthentication.new(email: 'test@commandp.com',
                                       password: 'commandp',
                                       password_confirmation: 'commandp'
                                      )
        expect { auth.user }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'raises ActiveRecord::RecordInvalid if password length is shorter than 8' do
        auth = EmailAuthentication.new(email: 'test@commandp.com',
                                       password: 'command',
                                       password_confirmation: 'command'
                                      )
        expect { auth.user }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'raises ActiveRecord::RecordInvalid if password is inconsistent with password_confirmation' do
        auth = EmailAuthentication.new(email: 'test@commandp.com',
                                       password: 'commandp',
                                       password_confirmation: 'commandggggg'
                                      )
        expect { auth.user }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'raises ActiveRecord::RecordInvalid if password_confirmation is empty' do
        auth = EmailAuthentication.new(email: 'test@commandp.com',
                                       password: 'commandp',
                                       password_confirmation: 'commandggggg'
                                      )
        expect { auth.user }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context 'when finds' do
      let!(:user) do
        create(:user, email: 'test@commandp.com',
                      password: 'commandp', password_confirmation: 'commandp')
      end
      let!(:user2) do
        create(:user, :without_confirmed, email: 'user2@commandp.com', password: 'commandp',
                                          password_confirmation: 'commandp')
      end

      it 'returns user if success' do
        auth = EmailAuthentication.new(email: 'test@commandp.com', password_input: 'commandp')
        expect(auth.user).to be_kind_of User
        expect(auth.user.email).to eq user.email
      end

      it 'raises ActiveRecord::RecordInvalid if password is invalid' do
        auth = EmailAuthentication.new(email: 'test@commandp.com', password_input: 'commandpggg')
        expect { auth.user }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'raises UserSignInError if email is invalid' do
        expect { EmailAuthentication.new(email: 'gggggg@commandp.com', password_input: 'commandp').user }
          .to raise_error UserSignInError
      end

      it 'raises ActiveRecord::RecordInvalid if email is unconfirmed' do
        auth = EmailAuthentication.new(email: 'user2@commandp.com',
                                       password: 'commandp',
                                       password_confirmation: 'commandp'
                                      )
        expect { auth.user }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end
end
