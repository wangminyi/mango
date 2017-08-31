module Admin::IngredientsHelper
  def format_price price
    "%.2f 元" % (price / 100.0) if price.present?
  end
end
