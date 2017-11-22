class ShopController < ApplicationController
  before_action :require_login, only: [:index, :wholesale]

  def index
    # 每日推荐
    # categories.push(
    #   name: "每日推荐",
    #   items: Dish.preload(dishes_ingredients: :ingredient).first(3).map(&:as_json),
    # )

    # 普通食材
    categories = Category.order(updated_at: :desc).map do |category|
      ingredients = category.categories_ingredients.order(priority: :desc, id: :asc).map(&:as_json)
      {
        id: category.id,
        name: category.name,
        item_relations: ingredients,
        items: [],
      }
    end

    gon.ingredients = Ingredient
      .ransack(
        price_not_null: true,
        image_not_null: true,
      ).result
      .ransack(
        m: 'or',
        stock_count_null: true,
        stock_count_gt: 0,
      ).result
      .preload(:dishes).map do |i|
        [i.id, i.as_json]
      end.to_h

    gon.categories = categories
    gon.addresses = current_user.addresses_json
    gon.is_admin = current_user.role.admin?
    gon.gifts = [
        {
          image: ActionController::Base.helpers.asset_url("gifts/gift_1.jpg"),
          limit: 3000,
          name: "中号沥水篮",
          count: 1,
          first_order: true,
          key: "first_order",
        },
        {
          image: ActionController::Base.helpers.asset_url("gifts/gift_2.jpg"),
          limit: 8000,
          name: "加厚沥水篮",
          count: 1,
          first_order: true,
          key: "first_order",
        },
        {
          image: ActionController::Base.helpers.asset_url("gifts/gift_3.jpg"),
          limit: 3900,
          ingredient_ids: Category.find_by(name: "火锅专区").categories_ingredients.where(secondary_tag: "精品丸类").pluck(:ingredient_id),
          name: "精美小碗",
          count: 1,
          key: "balls",
        }
      ]

    gon.first_order = !(Rails.env.production? && current_user.orders.with_pay_status(:paid).exists?)
    gon.settings = Settings.as_json
    gon.js_config_params = Wx.js_config_params(shop_index_url)
  end

  def wholesale
    entries = WholesaleEntry.where(visible: true)
      .preload(:wholesale_items)
      .order(updated_at: :desc)
      .map(&:as_json)

    gon.entries = entries
    gon.addresses = current_user.addresses_json

    gon.settings = Settings.as_json
    gon.js_config_params = Wx.js_config_params(shop_wholesale_url)
  end

  def wholesale_instances
    entry = WholesaleEntry.find(params[:id])
    instances = if entry.mode.platform?
      entry.visible_wholesale_instances
    else
      entry.visible_wholesale_instances.preload(wholesale_order: :user)
    end

    render json: {
      instances: WholesaleEntry.find(params[:id]).visible_wholesale_instances.map(&:as_json)
    }
  end
end
