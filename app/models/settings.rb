class Settings
  DISTRIBUTION_PRICE = 400
  FREE_DISTRIBUTION = 1000
  PREFERENTIAL_PRICE = 300
  GARDENS = %w(
              周浦兰廷九龙仓
              周浦逸亭佳苑
              周浦印象春城
              周浦明天华城
              周浦繁荣华庭
              周浦中金海棠湾
              周浦御沁园
              周浦绿地梧桐苑
              周浦绿地景汇佳苑
              康桥城中花园
              周浦汇丽苑
              周浦文馨园
              美林小城
              周浦菱翔苑
              南郊花园
              绿地东上海
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