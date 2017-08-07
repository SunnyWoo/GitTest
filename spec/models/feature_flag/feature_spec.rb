require 'spec_helper'

describe FeatureFlag::Feature do
  describe '.features' do
    it 'reads features from redis' do
      FeatureFlag::Feature.redis.sadd('features', 'editor')
      expect(FeatureFlag::Feature.features).to include('editor')
    end
  end

  describe '.add_feature' do
    it 'adds feature to redis' do
      FeatureFlag::Feature.add_feature('editor')
      expect(FeatureFlag::Feature.features).to include('editor')
    end
  end

  describe '#initialize' do
    it 'adds feature' do
      FeatureFlag::Feature.new('editor', double)
      expect(FeatureFlag::Feature.features).to include('editor')
    end
  end

  %w(admin user).each do |role|
    describe 'toggler methods' do
      it 'changes and store into redis' do
        feature = FeatureFlag::Feature.new('editor', double)
        expect(feature.send("enable_for_#{role}?")).to be(false)
        feature.send("enable_for_#{role}!")
        expect(feature.send("enable_for_#{role}?")).to be(true)
        feature.send("disable_for_#{role}!")
        expect(feature.send("enable_for_#{role}?")).to be(false)
      end
    end
  end

  describe '#determine' do
    context 'when feature is enable for admin' do
      let(:feature) { FeatureFlag::Feature.new('editor', controller) }
      before do
        feature.enable_for_admin!
      end

      context 'and user is admin' do
        let(:controller) { double(:controller, admin_signed_in?: true, user_signed_in?: false) }
        it 'yields for admin' do
          expect { |b| feature.determine(&b) }.to yield_control
        end
      end

      context 'and user is user' do
        let(:controller) { double(:controller, admin_signed_in?: false, user_signed_in?: true) }
        it 'not yields for user' do
          expect { |b| feature.determine(&b) }.not_to yield_control
        end
      end

      context 'and user is guest' do
        let(:controller) { double(:controller, admin_signed_in?: false, user_signed_in?: false) }
        it 'not yields for user' do
          expect { |b| feature.determine(&b) }.not_to yield_control
        end
      end
    end

    context 'when feature is enable for user' do
      let(:feature) { FeatureFlag::Feature.new('editor', controller) }
      before do
        feature.enable_for_user!
      end

      context 'and user is admin' do
        let(:controller) { double(:controller, admin_signed_in?: true, user_signed_in?: false) }
        it 'yields for admin' do
          expect { |b| feature.determine(&b) }.to yield_control
        end
      end

      context 'and user is user' do
        let(:controller) { double(:controller, admin_signed_in?: false, user_signed_in?: true) }
        it 'yields for user' do
          expect { |b| feature.determine(&b) }.to yield_control
        end
      end

      context 'and user is guest' do
        let(:controller) { double(:controller, admin_signed_in?: false, user_signed_in?: false) }
        it 'yields for user' do
          expect { |b| feature.determine(&b) }.to yield_control
        end
      end
    end

    context 'when feature is enable for user and admin' do
      let(:feature) { FeatureFlag::Feature.new('editor', controller) }
      before do
        feature.enable_for_admin!
        feature.enable_for_user!
      end

      context 'and user is admin' do
        let(:controller) { double(:controller, admin_signed_in?: true, user_signed_in?: false) }
        it 'yields for admin' do
          expect { |b| feature.determine(&b) }.to yield_control
        end
      end

      context 'and user is user' do
        let(:controller) { double(:controller, admin_signed_in?: false, user_signed_in?: true) }
        it 'yields for user' do
          expect { |b| feature.determine(&b) }.to yield_control
        end
      end

      context 'and user is guest' do
        let(:controller) { double(:controller, admin_signed_in?: false, user_signed_in?: false) }
        it 'yields for user' do
          expect { |b| feature.determine(&b) }.to yield_control
        end
      end
    end

    context 'when feature is enable for nobody' do
      let(:feature) { FeatureFlag::Feature.new('editor', controller) }

      context 'and user is admin' do
        let(:controller) { double(:controller, admin_signed_in?: true, user_signed_in?: false) }
        it 'not yields for admin' do
          expect { |b| feature.determine(&b) }.not_to yield_control
        end
      end

      context 'and user is user' do
        let(:controller) { double(:controller, admin_signed_in?: false, user_signed_in?: true) }
        it 'not yields for user' do
          expect { |b| feature.determine(&b) }.not_to yield_control
        end
      end

      context 'and user is guest' do
        let(:controller) { double(:controller, admin_signed_in?: false, user_signed_in?: false) }
        it 'not yields for user' do
          expect { |b| feature.determine(&b) }.not_to yield_control
        end
      end
    end
  end
end
