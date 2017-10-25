class Order < ApplicationRecord
  include OrderCommon

  extend Enumerize

  stores_emoji_characters :remark

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
    :refunded,
  ], scope: true, default: :unpaid

  ## associations
  belongs_to :user

  ## callbacks
  before_create :generate_order_no
  before_create :generate_item_details
  after_create :update_sales_volume

  ## validates
  validate :check_price, on: [:create]
  validate :check_stock, on: [:create]
  validates_presence_of :receiver_name, :receiver_address, :receiver_phone, :distribute_at

  def check_price
    total = self.ingredients_hash.map do |i, count|
      i.price * count
    end.sum

    garden = Garden.find_by(name: self.receiver_garden)
    if total < garden.free_price
      total += garden.distribution_price
    end

    # 优惠

    if total != self.total_price.to_i
      self.errors.add :total_price, "订单金额不符"
    end

    self.total_price = 1 if STAFF_IDS.include?(user.id)
  end

  def check_stock
    self.ingredients_hash.each do |i, count|
      if i.stock_count && i.stock_count < count
        self.errors.add :base, "订单数量超过库存，请刷新后调整购买数量"
        break
      end
    end
  end

  def apply_prepay ip: "127.0.0.1"
    wx_params = {
      body: '元也生鲜',
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

  # Hash
  # ingredient => count
  def ingredients_hash
    @__ingredients_hash ||= begin
      ingredients = Ingredient.where(id: self.item_list.map{|h| h["id"]}).preload(:category)
      self.item_list.map do |i|
        [ingredients.find{|ingredient| ingredient.id == i["id"]}, i["count"]]
      end.to_h
    end
  end

  def ingredients_count
    self.ingredients_hash.values.sum
  end

  # 批量订单的采购清单
  def self.bulk_ingredients
    category_hash = Hash.new{|h, k| h[k] = Hash.new{|h2, k2| h2[k2] = 0}}
    all.each do |order|
      order.ingredients_hash.each do |ingredient, count|
        key = "#{ingredient.alias} -- ￥#{(ingredient.price || 0) / 100.0} / #{ingredient.unit_text}"
        category_hash[ingredient.category.name][key] += count
      end
    end
    category_hash
  end

  def paid!
    if self.pay_status.unpaid?
      self.update(pay_status: :paid)
      set_stock
      SlackNotifier.notify_order(self)
    end
  end

  private
    def generate_order_no
      self.order_no = [Time.now.strftime("%Y%m%d%H%M%S"), "0" * 10, Random.rand(10_000_000..99_999_999).to_s].join
    end

    def generate_item_details
      self.item_details = self.ingredients_hash.map do |ingredient, count|
        ingredient.as_json.except(:description).merge(count: count)
      end
    end

    def update_sales_volume
      self.ingredients_hash.each do |ingredient, count|
        ingredient.update_column(:sales_volume, (ingredient.sales_volume + count))
      end
    end

    def set_stock
      self.ingredients_hash.each do |i, count|
        if i.stock_count
          i.update(stock_count: i.stock_count - count)
        end
      end
    end
end
