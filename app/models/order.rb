class Order < ApplicationRecord
  extend Enumerize

  serialize :item_details, JSON

  enumerize :status, in: [
    :submitted,
    :handling,
    :deliverying,
    :finished,
  ], scope: true, default: :submitted

  before_create :generate_order_no

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

  private
    def generate_order_no
      self.order_no = [Time.now.strftime("%F-%T"), Random.rand(1_000_000..9_999_999).to_s].join("-")
    end
end
