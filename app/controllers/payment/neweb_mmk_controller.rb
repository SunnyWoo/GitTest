class Payment::NewebMmkController < Payment::NewebController
  def begin
    super('mmk')
  end

  private

  def find_order
    super('mmk')
  end
end
