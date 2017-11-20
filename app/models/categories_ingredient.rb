class CategoriesIngredient < ApplicationRecord
  belongs_to :category
  belongs_to :ingredient

  def as_json
    {
      ingredient_id: ingredient_id,
      secondary_tag: secondary_tag,
    }
  end
end
