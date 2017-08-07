class ImpositionSampleBuilder
  include Sidekiq::Worker
  sidekiq_options queue: :adobe

  def perform(imposition_id)
    imposition = Imposition.find(imposition_id)
    imposition.build_sample
  end
end
