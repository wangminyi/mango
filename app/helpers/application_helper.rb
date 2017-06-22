module ApplicationHelper
  def format_price price
    "￥#{"%.2f" % (price.to_i / 100.0)}"
  end
end
