module WorkroundOriginalPrices
  extend ActiveSupport::Concern

  # 20151209 XXX: 因為特價有可能大於原價，且 client 端還未處理，所以先修改 api 為顯示價高者
  def original_prices
    object.original_prices['TWD'] < object.prices['TWD'] ? object.prices : object.original_prices
  end
end
