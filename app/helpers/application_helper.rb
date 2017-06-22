module ApplicationHelper
  def format_price price
    "￥#{format_price_without_unit(price)}"
  end

  def format_price_without_unit price
    "%.2f" % (price.to_i / 100.0)
  end
end
