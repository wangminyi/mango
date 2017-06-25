class Settings
  DISTRIBUTION_PRICE = 400
  FREE_DISTRIBUTION = 1000
  PREFERENTIAL_PRICE = 300
  GARDENS = %w(
              周浦兰廷九龙仓
              周浦印象春城
              周浦明天华城
              周浦繁荣华庭
              周浦中金海棠湾
              周浦御沁园
              周浦绿地梧桐苑
              周浦绿地景汇佳苑
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