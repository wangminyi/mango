class Ingredient < ApplicationRecord
  has_and_belongs_to_many :category
  has_many :dishes_ingredients, dependent: :destroy
  has_many :dishes, through: :dishes_ingredients
end
