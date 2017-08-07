require 'spec_helper'

describe MergeUserService do
  Given!(:from_user) { create(:user) }
  Given!(:to_user) { create(:user) }

  context '.migrate_data' do
    context 'fail ParametersInvalidError unless all users' do
      Then { expect { MergeUserService.migrate_data(from_user, nil) }.to raise_error(ParametersInvalidError) }
    end

    context 'fail ApplicationError if they are the same users' do
      Given(:msg) { 'Already the same user' }
      Then { expect { MergeUserService.migrate_data(from_user, from_user) }.to raise_error(AlreadySameUserError, msg) }
    end

    context 'should call' do
      before do
        expect(MergeUserService).to receive(:migrate_work).with(from_user.id, to_user.id)
        expect(MergeUserService).to receive(:migrate_order).with(from_user.id, to_user.id)
        expect(MergeUserService).to receive(:migrate_device).with(from_user.id, to_user.id)
        expect(MergeUserService).to receive(:migrate_wishlist).with(from_user.id, to_user.id)
        expect(MergeUserService).to receive(:migrate_tokens).with(from_user.id, to_user.id)
        expect(MergeUserService).to receive(:migrate_cart).with(from_user.id, to_user.id)
      end
      When { MergeUserService.migrate_data(from_user, to_user) }
      Then { from_user.reload.role == 'die' }
      And { from_user.migrate_to_user_id.to_i == to_user.id }
    end
  end

  context '.migrate_tokens' do
    Given!(:omniauth) { create(:omniauth, owner: from_user) }
    When { MergeUserService.migrate_tokens(from_user.id, to_user.id) }
    Then { from_user.reload.omniauths.count == 0 }
    And { to_user.reload.omniauths.count == 1 }
    And { to_user.omniauths.first.id == omniauth.id }
  end
end
