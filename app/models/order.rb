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
  validates_presence_of :receiver_name, :receiver_address, :receiver_phone

  def check_price
    total = self.ingredients_hash.map do |i, count|
      (i.price || 350) * count
    end.sum

    if total < Settings::FREE_DISTRIBUTION
      total += Settings::DISTRIBUTION_PRICE
    end

    # 优惠
    total -= Settings::PREFERENTIAL_PRICE

    if total != self.total_price.to_i
      self.errors.add :total_price, "订单金额不符"
    end
  end

  def apply_prepay ip: "127.0.0.1"
    wx_params = {
      body: '元也生鲜',
      out_trade_no: self.order_no,
      total_fee: self.total_price,
      spbill_create_ip: ip,
      notify_url: 'http://www.yylife.shop/wx/notify',
      trade_type: 'JSAPI',
      openid: self.user.open_id,
    }

    try_times = 0
    begin
      response = WxPay::Service.invoke_unifiedorder(wx_params)
      origin_data = WxPay::Service.generate_js_pay_req({
        prepayid: response["prepay_id"],
        noncestr: response["nonce_str"],
      })
      origin_data[:timestamp] = origin_data.delete(:timeStamp)
    rescue
      if try_times < 3
        try_times += 1
        retry
      else
        return nil
      end
    end
  end

  def ingredients_hash
    ingredients = Ingredient.where(id: self.item_details.map{|h| h["id"]})
    self.item_details.map do |i|
      [ingredients.find{|ingredient| ingredient.id == i["id"]}, i["count"]]
    end.to_h
  end

  def paid!
    order.update(pay_status: :paid)
  end

  private
    def generate_order_no
      self.order_no = [Time.now.strftime("%Y%m%d%H%M%S"), "0" * 10, Random.rand(10_000_000..99_999_999).to_s].join
    end
end
