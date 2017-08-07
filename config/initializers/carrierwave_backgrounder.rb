CarrierWave::Backgrounder.configure do |c|
  c.backend :sidekiq, queue: :process_images
end
