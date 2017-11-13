class Settings
  DISTRIBUTION_PRICE = 400
  FREE_DISTRIBUTION = 1000
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
              周浦泰苑公寓
              东丰林居
            )
  class << self
    def gardens
      Garden.where(visible: true).map do |garden|
        pinyin = Pinyin.t(garden.name, split: " ")
        garden.attributes.slice(
          "name",
          "address",
          "distribution_price",
          "free_price"
        ).merge(
          "chars" => pinyin.split.join,
          "first_letters" => pinyin.split.map{|chars| chars[0]}.join
        )
      end.sort_by do |garden|
        garden["first_letters"][0]
      end
    end

    def as_json
      {
        gardens: GARDENS, # 小区名称
        new_gardens: self.gardens, # 结构化小区
      }
    end

    def campaign_array
      [
        {
          code: "CISL",
          first_order: true,
          type: "discount",
          rate: 0.9,
          desc: "关注微信，首单九折"
        }
      ]
    end
  end
end
