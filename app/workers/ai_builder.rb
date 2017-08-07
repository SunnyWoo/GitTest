require 'fileutils'

class AiBuilder
  include Sidekiq::Worker
  sidekiq_options queue: :adobe

  def perform(work_gid)
    lock do
      @work = GlobalID::Locator.locate(work_gid)
      @work.logcraft_source = { channel: 'worker' }
      @work.create_activity('begin_build_ai')
      @work.build_ai
      @work.create_activity('end_build_ai')
    end
  end

  FILE_LOCK = '/tmp/.illustrator.lock'

  def lock
    sleep 1 while File.exist?(FILE_LOCK)
    begin
      FileUtils.touch(FILE_LOCK)
      yield
    ensure
      begin
        File.delete(FILE_LOCK)
      rescue
        warn "#{FILE_LOCK} is not exists."
      end
    end
  end
end
