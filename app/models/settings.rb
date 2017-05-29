class Settings
  DISTRIBUTION_PRICE = 400
  FREE_DISTRIBUTION = 1000
  PREFERENTIAL_PRICE = 300

  class << self
    def as_json
      {
        distribution_price: DISTRIBUTION_PRICE, # 配送费
        free_distribution: FREE_DISTRIBUTION, # 免配送费金额
        preferential_price: PREFERENTIAL_PRICE, # 优惠金额
      }
    end
  end
end