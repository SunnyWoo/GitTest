class Payment::NewebAtmController < Payment::NewebController
  def begin
    super('atm')
  end

  private

  def find_order
    super('atm')
  end
end
