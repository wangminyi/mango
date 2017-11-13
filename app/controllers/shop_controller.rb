class ShopController < ApplicationController
  before_action :require_login, only: [:index, :wholesale]

  def index
    categories = []

    # 每日推荐
    # categories.push(
    #   name: "每日推荐",
    #   items: Dish.preload(dishes_ingredients: :ingredient).first(3).map(&:as_json),
    # )

    # 普通食材
    Category.order(updated_at: :desc).each do |category|
      visible_ingredients = category.ingredients
        .where.not(price: nil)
        .where.not(image: nil)
        .where("ingredients.stock_count IS NULL OR ingredients.stock_count > 0")
        .preload(:dishes).order(priority: :desc, id: :asc).map(&:as_json)
      base_info = {
        id: category.id,
        name: category.name,
        items: visible_ingredients,
        with_secondary_tag: visible_ingredients.any?{|vi| vi[:secondary_tag].present?},
      }

      categories.push(base_info)
    end

    first_order = current_user.no_paid_order?
    gon.categories = categories.reject{|c| c[:items].blank?}
    gon.addresses = current_user.addresses_json
    gon.is_admin = current_user.role.admin?
    gon.coupons = current_user.coupons.visible.order(amount: :DESC).map(&:to_json)

    if first_order
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

  def search_campaign
    code = params[:campaign_code]&.upcase

    first_order = current_user.no_paid_order?
    campaign = Campaign.visible.where(code: code).map(&:to_json).reject do |campaign|
      campaign["first_order"] && !first_order
    end.first

    render json: {
      campaign: campaign
    }
  end
end
