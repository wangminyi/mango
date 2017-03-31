class Dish < ApplicationRecord
  has_many :dishes_ingredients, dependent: :destroy
  has_many :ingredients, through: :dishes_ingredients
end
