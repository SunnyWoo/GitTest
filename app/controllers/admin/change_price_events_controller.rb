class Admin::ChangePriceEventsController < AdminController
  def index
    @change_price_events = ChangePriceEvent.order(created_at: :desc).page(params[:page])
  end

  def new
    @form = Admin::ChangePriceEventForm.new(ChangePriceEvent.new)
  end

  def create
    change_price_event = ChangePriceEvent.new(operator: current_admin)
    @form = Admin::ChangePriceEventForm.new(change_price_event)
    @form.attributes = change_price_event_params
    @save_flag = @form.save
    respond_to do |format|
      format.js
    end
  end

  def target_list
    @form = Admin::ChangePriceEventForm.new(ChangePriceEvent.new, q: params[:q])
    @target_type = params[:target_type]
  end

  def rerun
    @change_price_event = ChangePriceEvent.find(params[:id])
    fail ApplicationError, 'Rerun Fail' unless @change_price_event.failed?
    @change_price_event.enqueue_change_price_worker
    redirect_to :back
  end

  def histories
    @change_price_event = ChangePriceEvent.find(params[:id])
    @histories = @change_price_event.change_price_histories.page(params[:page])
  end

  private

  def change_price_event_params
    params.require(:change_price_event).permit(:price_tier_id, :target_type, target_ids: [])
  end
end
