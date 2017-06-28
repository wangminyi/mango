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
  ], scope: true, default: :unpaid

  belongs_to :user
  belongs_to :wholesale_item
  belongs_to :wholesale_instance

  ## callbacks
  before_create :generate_order_no
  before_create :generate_item_details
  after_create :update_sales_volume

  def paid!
    super
    self.wholesale_instance.update(current_count: self.wholesale_instance.current_count + self.item_count)
  end

  def abandon!
    super
    self.wholesale_instance.update(current_count: self.wholesale_instance.current_count - self.item_count)
  end

  private
    def generate_order_no
      self.order_no = [Time.now.strftime("%Y%m%d%H%M%S"), "0" * 9, Random.rand(100_000_000..999_999_999).to_s].join
    end

    def generate_item_details
      self.item_details = [
        self.wholesale_item.as_json
      ]
    end

    def update_sales_volume
      self.wholesale_item.update_column(:sales_volume, (self.wholesale_item.sales_volume + self.item_count))
    end
end
