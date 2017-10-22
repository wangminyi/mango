class WholesaleOrder < ApplicationRecord
  extend Enumerize

  include OrderCommon

  stores_emoji_characters :remark

  serialize :item_details, JSON

  enumerize :status, in: [
    :submitted, # 待处理
    :distributing, #正在送货
    :finished, # 完成订单
    :abandon, # 废弃
  ], scope: true, default: :submitted

  enumerize :pay_status, in: [
    :unpaid,
    :paid,
    :refunded,
  ], scope: true, default: :unpaid

  belongs_to :user
  belongs_to :wholesale_item
  belongs_to :wholesale_instance

  ## callbacks
  before_create :generate_order_no
  before_create :generate_item_details
  after_create :update_sales_volume

  ## validates
  # validate :check_stock
  validate :check_validate, on: [:create]
  validates_presence_of :receiver_name, :receiver_address, :receiver_phone, :distribute_at

  def check_validate
    total = self.wholesale_item.price * self.item_count

    if total != self.total_price.to_i
      self.errors.add :total_price, "订单金额不符"
    end

    if self.wholesale_instance.mode.user? && WholesaleOrder.exists?(wholesale_instance_id: self.wholesale_instance_id, user_id: self.user_id)
      self.errors.add :user_exist, "您已参加过该次拼团"
    end

    self.total_price = 1 if STAFF_IDS.include?(user.id)
  end

  def apply_prepay ip: "127.0.0.1"
    wx_params = {
      body: '元也拼团',
      out_trade_no: self.order_no,
      total_fee: self.total_price,
      spbill_create_ip: ip,
      notify_url: 'http://www.yylife-sh.com/wx/notify',
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
      origin_data
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
    self.update(pay_status: :paid)
    self.wholesale_instance.update(current_count: self.wholesale_instance.current_count + self.item_count)
  end

  def abandon!
    self.update(status: :abandon)
    self.wholesale_instance.update(current_count: self.wholesale_instance.current_count - self.item_count)
  end

  private
    def generate_order_no
      self.order_no = [Time.now.strftime("%Y%m%d%H%M%S"), "0" * 9, Random.rand(100_000_000..999_999_999).to_s].join
    end

    def generate_item_details
      self.item_details = [
        self.wholesale_item.as_json.merge(count: self.item_count)
      ]
    end

    def update_sales_volume
      self.wholesale_item.update_column(:sales_volume, (self.wholesale_item.sales_volume + self.item_count))
    end
end
