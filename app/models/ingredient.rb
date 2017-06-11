class Ingredient < ApplicationRecord
  extend Enumerize

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
      tags:   self.tags&.split(",") || [],
      price:    self.price || 350,
      unit_text: "/" + (self.unit_text || "约500g"),
      count:    0,
      texture:  self.texture,
      order_limit: self.order_limit, # 上限
      limit_count: self.limit_count, # 起卖
      description: self.description,
      sales_volume: self.sales_volume || 0
    }
  end
end
