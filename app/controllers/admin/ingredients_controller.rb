class Admin::IngredientsController < Admin::BaseController
  before_action :set_ingredient, only: [:edit, :update]

  def index
    respond_to do |format|
      format.html
      format.json do
        keyword = params[:keyword]

        ingredients = Ingredient.all

        keyword.split.each do |word|
          ingredients = ingredients.where("alias LIKE ?", "%#{word}%")
        end

        render json:  {
          html: render_to_string(partial: "table", locals: {ingredients: ingredients})
        }
      end
    end
  end

  def edit
  end

  def update
    @ingredient.update(ingredient_params)
    head :ok
  end

  private
    def set_ingredient
      @ingredient = Ingredient.find(params[:id])
    end

    def ingredient_params
      params.require(:ingredient).permit(
        :alias,
        :price,
        :original_price,
        :sales_volume,
        :secondary_tag,
        :is_hot,
      )
    end
end
