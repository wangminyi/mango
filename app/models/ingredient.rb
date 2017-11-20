class Ingredient < ApplicationRecord
  extend Enumerize

  has_many :categories_ingredients
  has_many :categories, through: :categories_ingredients
  has_many :dishes_ingredients, dependent: :destroy
  has_many :dishes, through: :dishes_ingredients

  serialize :description, JSON

  def as_json
    {
      id:     self.id,
      name:   self.alias || self.name,
      origin_name: self.name,
      image:  (ActionController::Base.helpers.asset_url(self.image) rescue ""),
      label:  self.dishes.present? ? "推荐食谱：#{self.dishes.first(3).map(&:name).join('、')}" : "",
      tags:   self.tags&.split(",") || [],
      price:    self.price,
      unit_text: "/" + (self.unit_text || "约500g"),
      count:    0,
      texture:  self.texture,
      order_limit: self.order_limit || self.stock_count, # 上限
      limit_count: self.limit_count, # 起卖
      description: parsed_description,
      sales_volume: self.sales_volume || 0,
      secondary_tag: self.secondary_tag,
      is_hot: self.is_hot,
      original_price: self.is_hot? ? self.original_price : nil,
      stock_count: self.stock_count || 0,
    }
  end

  def parsed_description
    self.description.map do |list|
      if list["type"] == "image"
        list.merge(
          content: ActionController::Base.helpers.asset_url(list["content"])
        )
      else
        list
      end
    end
  rescue
    nil
  end
end
