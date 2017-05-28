class Order < ApplicationRecord
  extend Enumerize

  serialize :item_details, JSON

  enumerize :status, in: [
    :submitted,
    :handling,
    :deliverying,
    :finished,
  ], scope: true, default: :submitted

  enumerize :pay_status, in: [
    :unpaid,
    :paid,
  ], scope: true, default: :unpaid

  ## associations
  belongs_to :user

  ## callbacks
  before_create :generate_order_no

  ## validates
  # validate :check_stock
  validate :check_price, on: [:create]


  def check_price
    items = self.item_details

    total = Ingredient.where(id: items.keys).map do |i|
      (i.price || 350) * items[i.id.to_s].to_i
    end.sum

    if total != self.item_price.to_i
      self.errors.add :item_price, "订单金额不符"
    end
  end

  def apply_prepay ip: "127.0.0.1"
    wx_params = {
      body: '测试',
      out_trade_no: self.order_no,
      total_fee: self.total_price,
      spbill_create_ip: ip,
      notify_url: 'http://yylife.online/wx/notify',
      trade_type: 'JSAPI',
      openid: order.user.openid,
    }

    try_times = 0
    begin
      response = WxPay::Service.invoke_unifiedorder(wx_params)
      # => {
      #      "return_code"=>"SUCCESS",
      #      "return_msg"=>"OK",
      #      "appid"=>"YOUR APPID",
      #      "mch_id"=>"YOUR MCH_ID",
      #      "nonce_str"=>"8RN7YfTZ3OUgWX5e",
      #      "sign"=>"623AE90C9679729DDD7407DC7A1151B2",
      #      "result_code"=>"SUCCESS",
      #      "prepay_id"=>"wx2014111104255143b7605afb0314593866",
      #      "trade_type"=>"JSAPI"
      #    }
      return WxPay::Service.generate_js_pay_req({
        prepayid: response["prepay_id"],
        noncestr: response["nonce_str"],
      })
    rescue
      if try_times < 3
        try_times += 1
        retry
      else
        return nil
      end
    end
  end

  def paid!
    order.update(pay_status: :paid)
  end

  private
    def generate_order_no
      self.order_no = [Time.now.strftime("%Y%m%d%H%M%S"), "0" * 10, Random.rand(10_000_000..99_999_999).to_s].join("-")
    end
end