class Dish < ApplicationRecord
  has_many :dishes_ingredients, dependent: :destroy
  has_many :ingredients, through: :dishes_ingredients


  def as_json
    {
      name: self.name,
      type: "dish",
      image: ActionController::Base.helpers.asset_url(self.image || "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg"),
      label: "所需食材：#{self.ingredients.map(&:name).join("、")}",
      price: self.price,
      items: self.items_json,
      cooking_method: self.cooking_method,
    }
  end

  def price
    result = 0
    self.dishes_ingredients.each do |di|
      total_weight = di.weight || 500
      unit_weight  = di.ingredient.weight || 500
      single_price = (total_weight / unit_weight.to_f).ceil * (di.ingredient.price || 350)

      result += single_price
    end

    result
  end

  def items_json
    self.dishes_ingredients.map do |di|
      total_weight = di.weight || 500
      unit_weight  = di.ingredient.weight || 500
      {
        id: di.ingredient_id,
        count: (total_weight / unit_weight.to_f).ceil,
      }
    end
  end
end
