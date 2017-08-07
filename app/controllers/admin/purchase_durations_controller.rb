class Admin::PurchaseDurationsController < AdminController
  def index
    @durations = Purchase::Duration.includes(histories: [product: :translations]).all
  end
end
