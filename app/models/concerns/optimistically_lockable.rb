module OptimisticallyLockable
  extend ActiveSupport::Concern
  included do
    self.lock_optimistically = false
  end

  module ClassMethods
    def with_optimistic_locking
      self.lock_optimistically = true

      begin
        yield
      ensure
        self.lock_optimistically = false
      end
    end
  end
end
