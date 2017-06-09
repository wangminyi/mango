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
    Category.all.each do |category|
      base_info = {
        name: category.name,
        items: category.ingredients.preload(:dishes).map(&:as_json),
      }

      categories.push(base_info)
    end

    gon.categories = categories
    gon.addresses = current_user.addresses_json
    gon.gifts = [
      {
        image: "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg",
        limit: "1000",
        name: "菜篮子",
        count: 1,
        label: "好篮子",
        price: 5000,
      },
      {
        image: "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg",
        limit: "2000",
        name: "拖把",
        label: "好拖把",
        count: 2,
        price: 6000,
      }
    ]
    gon.settings = Settings.as_json
    gon.js_config_params = Wx.js_config_params(shop_index_url)
  end
end
