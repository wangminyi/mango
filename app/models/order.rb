class Order < ApplicationRecord
  extend Enumerize

  stores_emoji_characters :remark

  STAFF_IDS = [2, 3]

  serialize :item_list, JSON
  serialize :item_details, JSON
  serialize :gifts, JSON

  enumerize :status, in: [
    :submitted, # 待处理
    :arranging, # 正在配单
    :arranged,  # 等待发货
    :distributing, #正在送货
    :finished, # 完成订单
    :abandon, # 废弃
  ], scope: true, default: :submitted

  enumerize :pay_status, in: [
    :unpaid,
    :paid,
  ], scope: true, default: :unpaid

  ## associations
  belongs_to :user

  ## callbacks
  before_create :generate_order_no
  before_create :generate_item_details
  after_create :update_sales_volume

  ## validates
  # validate :check_stock
  validate :check_price, on: [:create]
  validates_presence_of :receiver_name, :receiver_address, :receiver_phone

  def check_price
    total = self.ingredients_hash.map do |i, count|
      i.price * count
    end.sum

    if total < Settings::FREE_DISTRIBUTION
      total += Settings::DISTRIBUTION_PRICE
    end

    # 优惠

    if total != self.total_price.to_i
      self.errors.add :total_price, "订单金额不符"
    end

    self.total_price = 1 if STAFF_IDS.include?(user.id)
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

  def ingredients_hash
    @__ingredients_hash ||= begin
      ingredients = Ingredient.where(id: self.item_list.map{|h| h["id"]}).preload(:dishes)
      self.item_list.map do |i|
        [ingredients.find{|ingredient| ingredient.id == i["id"]}, i["count"]]
      end.to_h
    end
  end

  def ingredients_count
    self.ingredients_hash.values.sum
  end

  def paid!
    self.update(pay_status: :paid)
  end

  def arranging!
    self.status.submitted? && self.update(status: :arranging)
  end

  def arranged!
    self.status.arranging? && self.update(status: :arranged)
  end

  def distributing!
    self.status.arranged? && self.update(status: :distribuing)
  end

  def finished!
    self.status.distribuing? && self.update(status: :finished)
  end

  def can_abandon?
    %w(finished abandon).exclude? self.status
  end

  def abandon!
    self.update(status: :abandon)
  end

  def can_push_state?
    %w(finished abandon).exclude? self.status
  end

  def next_state!
    if ( _next_state = self.next_state_value).present?
      self.update(status: _next_state)
    end
  end

  # 下一步的状态
  def next_state_value
    options = self.class.status.values
    if (index = options[0...-2].index(self.status)).present?
      options[index + 1]
    end
  end

  # 下一步的文案
  def next_state_text
    options = self.class.status.options
    if (index = options[0...-2].index{|s| s[1] == self.status}).present?
      options[index + 1][0]
    end
  end

  def total_price_yuan
    '%.2f' % (self.total_price / 100.0)
  end

  def distribute_at_text
    "#{self.distribute_at.strftime("%F %H:00")} ~ #{self.distribute_at.since(1.hour).strftime("%H:00")}"
  end

  private
    def generate_order_no
      self.order_no = [Time.now.strftime("%Y%m%d%H%M%S"), "0" * 10, Random.rand(10_000_000..99_999_999).to_s].join
    end

    def generate_item_details
      self.item_details = self.ingredients_hash.map do |ingredient, count|
        ingredient.as_json.merge(count: count)
      end
    end

    def update_sales_volume
      self.ingredients_hash.each do |ingredient, count|
        ingredient.update_column(:sales_volume, (ingredient.sales_volume + count))
      end
    end
end
