class Imposition::DemoBuilder
  include Sidekiq::Worker
  sidekiq_options queue: :adobe, retry: 0

  def perform(imposition_id, email)
    illustrator = IllustratorService.new
    illustrator.quit

    imposition = Imposition.find(imposition_id)
    work = [
      imposition.model.works.is_public.last,
      Work.is_public.last
    ].compact.first
    items = imposition.slice_size.times.map { |i| MockPrintItem.new(work, i) }
    printable = imposition.build_printable(items)
    attachment = Attachment.new(file: File.open(printable))
    PrintMailer.imposition_demo(email, imposition, attachment).deliver
  rescue
    PrintMailer.imposition_demo_failure(email, $ERROR_INFO).deliver
  end

  # 從 ProductModel 找 PrintItem 實在太太太太太太太太太太太太太麻煩了, 不如自己 mock 一個
  class MockPrintItem
    attr_reader :work, :id

    def initialize(work, id)
      @work = work
      @id = id
    end

    def order_item
      self
    end

    def order
      self
    end

    def order_no
      '15xxxxxxxxTW'
    end

    def itemable
      @work
    end

    def print_image
      @work.print_image
    end

    def timestamp_no
      Time.zone.now.to_i
    end
  end
end
