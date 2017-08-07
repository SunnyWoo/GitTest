class BdeventsController < ApplicationController
  layout 'app'

  def index
    @bdevents = Bdevent.event_available
    @comings = Bdevent.coming_available if @bdevents.size == 0
    @header_title = '兌換專區'
  end
end
