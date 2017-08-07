class Admin::PriceTiersController < AdminController
  def index
    @price_tiers = PriceTier.ordered
    @currencies = CurrencyType.pluck(:code)

    respond_to do |f|
      f.html
      f.json { render json: @price_tiers, meta: { current_currency_code: current_currency_code } }
    end
  end

  def update
    tiers = params[:changeset]
    PriceTierUpdaterService.new(params[:changeset]).save
    render json: PriceTier.all
  end

  def show
    @price_tier = PriceTier.find(params[:id])
    render layout: false
  end
end
