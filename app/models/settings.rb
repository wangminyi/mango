class Settings
  DISTRIBUTION_PRICE = 400
  FREE_DISTRIBUTION = 1000
  PREFERENTIAL_PRICE = 300

  class << self
    def as_json
      {
        distribution_price: DISTRIBUTION_PRICE,
        free_distribution: FREE_DISTRIBUTION,
        preferential_price: PREFERENTIAL_PRICE,
      }
    end
  end
end