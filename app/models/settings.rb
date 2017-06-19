class Settings
  DISTRIBUTION_PRICE = 400
  FREE_DISTRIBUTION = 1000
  PREFERENTIAL_PRICE = 300
  GARDENS = %w(
              周浦印象春城
              周浦逸亭佳苑
              周浦兰亭-九龙仓
              周浦惠康公寓
            )
  class << self
    def as_json
      {
        gardens: GARDENS, # 小区名称
        distribution_price: DISTRIBUTION_PRICE, # 配送费
        free_distribution: FREE_DISTRIBUTION, # 免配送费金额
        preferential_price: PREFERENTIAL_PRICE, # 优惠金额
      }
    end
  end
end