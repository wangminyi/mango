class Ingredient < ApplicationRecord
  belongs_to :category
  has_many :dishes_ingredients, dependent: :destroy
  has_many :dishes, through: :dishes_ingredients

  def as_json
    {
      id:     self.id,
      name:   self.name,
      type:   "ingredient",
      image:  ActionController::Base.helpers.asset_url(self.image || "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg"),
      label:  self.dishes.present? ? "推荐食谱：#{self.dishes.first(3).map(&:name).join('、')}" : "",
      discount: self.discount.present?,
      price:    self.price || 350,
      weight:   self.weight || 500,
      count:    (self.id % 10) === 0 ? 1 : 0,
      texture:  self.texture || "口感不错",
    }
  end
end
