class Category < ApplicationRecord
  has_many :categories_ingredients
  has_many :ingredients, through: :categories_ingredients
end
