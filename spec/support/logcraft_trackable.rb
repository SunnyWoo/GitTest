RSpec.shared_examples 'logcraft trackable' do
  it { should have_many(:activities) }

  describe '#create_activity' do
    it 'creates activity with given key' do
      trackable.create_activity(:hello)
      activity = trackable.activities.find_by!(key: 'hello')
    end

    it 'creates activity with given key and user' do
      user = create(:user)
      trackable.create_activity(:hello, user: user)
      activity = trackable.activities.find_by!(key: 'hello')
      expect(activity.user).to eq(user)
    end

    it 'creates activity with given key, user and source' do
      user = create(:user)
      trackable.create_activity(:hello, user: user, source: {channel: 'api'})
      activity = trackable.activities.find_by!(key: 'hello')
      expect(activity.key).to eq('hello')
      expect(activity.user).to eq(user)
      expect(activity.source).to eq('channel' => 'api')
    end

    it 'creates activity with given key, user, source and message' do
      user = create(:user)
      trackable.create_activity(:hello, user: user, source: {channel: 'api'}, message: 'buy buy')
      activity = trackable.activities.find_by!(key: 'hello')
      expect(activity.key).to eq('hello')
      expect(activity.user).to eq(user)
      expect(activity.source).to eq('channel' => 'api')
      expect(activity.message).to eq('buy buy')
    end

    it 'creates activity with given key, user, source, message and extra info' do
      user = create(:user)
      trackable.create_activity(:hello, user: user, source: {channel: 'api'}, message: 'buy buy', extra1: '1', extra2: '2')
      activity = trackable.activities.find_by!(key: 'hello')
      expect(activity.key).to eq('hello')
      expect(activity.user).to eq(user)
      expect(activity.source).to eq('channel' => 'api')
      expect(activity.message).to eq('buy buy')
      expect(activity.extra_info).to eq('extra1' => '1', 'extra2' => '2')
    end

    it 'creates activity with logcraft_*' do
      user = create(:user)
      trackable.logcraft_user = user
      trackable.logcraft_source = {channel: 'api'}
      trackable.logcraft_message = 'buy buy'
      trackable.logcraft_extra_info = {extra1: '1', extra2: '2'}
      trackable.create_activity(:hello)
      activity = trackable.activities.find_by!(key: 'hello')
      expect(activity.key).to eq('hello')
      expect(activity.user).to eq(user)
      expect(activity.source).to eq('channel' => 'api')
      expect(activity.message).to eq('buy buy')
      expect(activity.extra_info).to eq('extra1' => '1', 'extra2' => '2')
    end
  end
end
