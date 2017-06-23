class ShopController < ApplicationController
  before_action :require_login, only: [:index]
  def index
    categories = []

    # 每日推荐
    # categories.push(
    #   name: "每日推荐",
    #   items: Dish.preload(dishes_ingredients: :ingredient).first(3).map(&:as_json),
    # )

    # 普通食材
    Category.order(updated_at: :desc).each do |category|
      base_info = {
        name: category.name,
        items: category.ingredients.where.not(price: nil).preload(:dishes).order(priority: :desc).map(&:as_json),
      }

      categories.push(base_info)
    end

    gon.categories = categories
    gon.addresses = current_user.addresses_json

    if !(Rails.env.production? && current_user.orders.with_pay_status(:paid).exists?)
      gon.first_order = true
      gon.gifts = [
        {
          image: ActionController::Base.helpers.asset_url("gifts/gift_1.jpg"),
          limit: 3000,
          name: "中号沥水篮",
          count: 1,
        },
        {
          image: ActionController::Base.helpers.asset_url("gifts/gift_2.jpg"),
          limit: 8000,
          name: "加厚沥水篮",
          count: 1,
        }
      ].sort_by{|gift| -gift[:limit]}
    end

    gon.settings = Settings.as_json
    gon.js_config_params = Wx.js_config_params(shop_index_url)
  end
end
