class Webhook::NewebMppController < Webhook::NewebController
  def writeoff
    # 訂單使用藍新付款 若重新請求付款方式 訂單編號會更改 會導致 callback 失敗
    # https://app.asana.com/0/14529796148307/28231481273943
    @order_no = params['OrderNumber']
    find_order_and_finish
  end
end
