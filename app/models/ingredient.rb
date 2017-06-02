class Ingredient < ApplicationRecord
  extend Enumerize

  enumerize :sale_mode, in: [
    :gram, # 克
    :liang, # 两
    :count, # 个
  ], scope: true, default: :gram

  belongs_to :category, optional: true
  has_many :dishes_ingredients, dependent: :destroy
  has_many :dishes, through: :dishes_ingredients

  serialize :description, JSON

  def as_json
    {
      id:     self.id,
      name:   self.alias || self.name,
      image:  ActionController::Base.helpers.asset_url(self.image || "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg"),
      label:  self.dishes.present? ? "推荐食谱：#{self.dishes.first(3).map(&:name).join('、')}" : "",
      discount: self.discount.present?,
      price:    self.price || 350,
      weight:   self.weight || 500,
      unit: self.sale_mode_text,
      count:    self.id % 10 === 0 ? 1 : 0,
      texture:  self.texture,
      order_limit: self.order_limit, # 上限
      limit_count: self.limit_count, # 起卖
      description: self.description,
    }
  end

  def unit
  end
end
