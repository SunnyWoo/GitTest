class CleanWorksCache
  include Sidekiq::Worker
  def perform
    Work.is_public.find_each(&:touch)
  end
end
