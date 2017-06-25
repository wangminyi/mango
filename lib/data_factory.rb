class DataFactory
  require "csv"

  class << self
    def clean_data
      Category.delete_all
      Ingredient.delete_all
      Dish.delete_all
      DishesIngredient.delete_all
    end

    def import_data
      import_ingredient
      # import_dishes
      # import_cooking_method
    end

    def init_categories
      %w(本地时令 水产类 蔬菜类 肉禽类 豆制品 蛋类 面食类 调味料 元也特色).each do |name|
        Category.find_or_create_by(name: name)
      end
    end

    def import_ingredient
      Category.all.each do |category|
        CSV.foreach("./data_files/#{category.name}.csv") do |line|
          next if line[0].blank?
          ingredient = Ingredient.create(
            category: category,
            name: line[0],
            alias: line[1].presence,
          )
          import_ingredients_img(ingredient)
          line[2..4].reject(&:blank?).each do |dish_name|
            dish = Dish.find_or_create_by(name: dish_name)
            dish.ingredients << ingredient
          end
        end
      end
    end

    def import_new_ingredient
      CSV.foreach("./data_files/v3.csv") do |line|
        next if line[0].blank?
        ingredient = Ingredient.create(
          name: line[0],
          alias: line[1].presence,
        )
        import_ingredients_img(ingredient)
        line[2..4].reject(&:blank?).each do |dish_name|
          dish = Dish.find_or_create_by(name: dish_name)
          dish.ingredients << ingredient
        end
      end
    end

    def import_dishes
      undefined_ingredients = []
      CSV.foreach("./data_files/dishes.csv") do |line|
        data = line.reject(&:blank?)
        next if data.length < 2

        dish = Dish.create(
          name: data[0],
        )

        data[1..-1].each do |ingredient|
          i = Ingredient.find_by(name: ingredient)
          if i.present?
            dish.ingredients << i
          else
            undefined_ingredients << ingredient
          end
        end
      end

      puts "未找到的食材：#{undefined_ingredients.uniq.join(",")}"
    end

    def import_cooking_method
      undefined_dishes = []
      CSV.foreach("./data_files/methods.csv") do |line|
        data = line.reject(&:blank?)
        next if data.length < 2

        cm = data[1].split(/[0-9]./).reject(&:blank?)
        method_text = cm.map.with_index do |step, index|
          "#{index + 1}. #{step.strip}"
        end.join("\n")
        dish = Dish.find_by(name: data[0])
        if dish.present?
          dish.update(cooking_method: method_text)
        else
          undefined_dishes << line[0]
        end
      end

      puts undefined_dishes.join(",")
    end

    def import_dishes_img
      dir_path = File.join(Rails.root + "app/assets/images")
      Dish.all.each do |dish|
        relative_path = "dishes/#{dish.name}.jpg"
        file = File.join(dir_path, relative_path)
        if File.exists? file
          dish.update_attribute(:image, relative_path)
        end
      end
    end

    def import_ingredients_img ingredient
      dir_path = File.join(Rails.root + "app/assets/images")
      suffixes = ["jpg"]

      relative_path = nil

      suffixes.each do |suffix|
        temp_path = if ingredient.category.present?
          "ingredients/#{ingredient.category.name}/#{ingredient.name}.#{suffix}"
        else
          "ingredients/v3/#{ingredient.name}.#{suffix}"
        end

        file = File.join(dir_path, temp_path)
        if File.exists? file
          relative_path = temp_path
          break
        end
      end

      if relative_path.present?
        ingredient.update_attribute(:image, relative_path)
      else
        puts ingredient.name
      end
    end

    def crawl_jd
      url = "https://daojia.jd.com/client.json"
      cat_ids = {
        # "蔬菜": %w(
        #           4360808
        #           4360806
        #           4360804
        #           4360805
        #           4360807
        #         ),
        # "肉类": %w(
        #           4350411
        #           4350412
        #         ),
        # "蛋类": ["4054051"],
        # "干货": ["4017881"],
        # "米面": ["4350417", "4350416", "4350415"],
        "豆制品": ["4054057"],
        "水产": ["4017262"]
      }

      require "open-uri"

      cat_ids.each do |cat_name, id_arrays|
        id_arrays.each do |cat_id|
          options = {
            functionId: "productsearch/search",
            body: '{"ref":"index/LID:6","key":"","catId":"' + cat_id + '","storeId":"10030295","sortType":1,"page":1,"pageSize":200,"cartUuid":"","promotLable":"","timeTag":1494221919172}',
            appVersion: '4.1.0',
            appName: 'paidaojia',
            platCode: 'H5',
            lng: '121.47369',
            lat: '31.23035',
            city_id: '2'
          }
          j = JSON.parse(RestClient.get("#{url}?#{options.to_query}").to_s)["result"]["searchResultVOList"]
          j.each do |item|
            begin
              name = item["skuName"].gsub("/", "_")
              img = item["imgUrl"]
              suffix = img.split(".")[-1]
              open(img) do |f|
                File.open("/Users/zenglingwu/Downloads/jd/#{cat_name}/#{name}.#{suffix}", "wb") do |file|
                  file.puts f.read
                end
              end
            rescue
              puts "抓取失败: #{name} #{img}"
            end
          end
        end
      end
    end

    def ingredient_details
      name = %w(本地玉米 本地丝瓜 本地黄瓜 本地茄子 本地薄皮青椒 本地小叶韭菜 本地红苋菜)
      data = [
        [
          {
            type: :image,
            content: "description/玉米1.jpg",
          },
          {
            type: :image,
            content: "description/玉米2.jpg",
          },
          {
            type: :text,
            content: "南汇本地人自家种植的玉米，产量不高但质量绝对过优，每到夏天，几乎每个晚上都要啃上2条自家种植的玉米才过瘾。玉米会稍有一些虫蛀，但整体并不影响美观，这也是未打农药的见证。",
          },
          {
            type: :image,
            content: "description/玉米3.jpg",
          },
          {
            type: :text,
            content: "玉米颗粒饱满，个头适中，颜色呈乳白色并泛着淡淡的米黄色。清水煮熟后直接开啃最是美味，鲜嫩十足并带有微微甜味，回味无穷。",
          },
          {
            type: :text,
            content: "与市面上的白玉米有非常明显的口感差别，试过才知道什么才是真正的好玉米。玉米也是季节性产物，错过这一季，也要等一年，在时令季节把美味吃个够吧～",
          },
        ],
        [
          {
            type: :image,
            content: "description/丝瓜1.jpg",
          },
          {
            type: :text,
            content: "本地的丝瓜都是现订现摘，所以摸上去的手感比较硬，不软，非常容易削皮，水分也足。削皮后丝瓜肉质绿嫩，是看得见的新鲜，烧熟后入口爽嫩回味甘甜，绝对区别于市面上的大棚丝瓜。",
          },
          {
            type: :image,
            content: "description/丝瓜2.jpg",
          },
          {
            type: :text,
            content: "本地人种植的丝瓜长度较短，一根的长度大概在25cm左右，一般市售的丝瓜在35cm以上，所以如果是炒来吃的话一盆建议使用3～4根丝瓜比较合适。",
          },
          {
            type: :image,
            content: "description/丝瓜3.jpg",
          },
          {
            type: :text,
            content: "本地丝瓜和普通丝瓜从外观上也比较容易区分，本地的丝瓜凸起的纹路会少于普通丝瓜，且丝瓜皮的颜色更翠绿一些。削皮后，本地丝瓜瓜肉较白，普通会有筋的纹路且颜色淡绿（使用的是同一个削皮工具）。",
          },
          {
            type: :image,
            content: "description/丝瓜4.jpg",
          },
          {
            type: :text,
            content: "看横截面的话普通丝瓜分为2层，里层白肉外层青绿，本地丝瓜则只有一层。斜截面里，很明显本地丝瓜有籽的颗粒感，普通丝瓜稍少。",
          },
        ],
        [
          {
            type: :image,
            content: "description/黄瓜1.jpg",
          },
          {
            type: :image,
            content: "description/黄瓜2.jpg",
          },
          {
            type: :image,
            content: "description/黄瓜3.jpg",
          },
          {
            type: :text,
            content: "南汇本地人在自家田地里自搭简易棚架，为黄瓜做一个漂亮的攀藤架，非暖棚，完全露天状态，让黄瓜自然生长。",
          },
          {
            type: :image,
            content: "description/黄瓜4.jpg",
          },
          {
            type: :text,
            content: "本地黄瓜多长得比较粗壮且相对较短，不太好看，和普通黄瓜对比，一副“矮穷矬”的样子。瓜皮颜色也不均匀，但是一看就是天然健康的样子。",
          },
          {
            type: :image,
            content: "description/黄瓜5.jpg",
          },
          {
            type: :image,
            content: "description/黄瓜6.jpg",
          },
          {
            type: :text,
            content: "削皮后，差别不大，但是从截面来看，本地黄瓜的籽更大（当然本地黄瓜本身就粗壮一些），瓜肉颜色相对较白一些。",
          },
          {
            type: :text,
            content: "本地人有个非常美味的黄瓜吃法，将黄瓜籽用勺子刮出后放入碗中，加入适量白糖，搅拌均匀放冰箱冷藏一会再取出食用，非常解暑好吃！",
          },
          {
            type: :text,
            content: "本地黄瓜非常适合榨汁，出汁量非常惊人，而且口感清甜。",
          },
        ],
        [
          {
            type: :image,
            content: "description/茄子1.jpg",
          },
          {
            type: :image,
            content: "description/茄子2.jpg",
          },
          {
            type: :image,
            content: "description/茄子3.jpg",
          },
          {
            type: :text,
            content: "本地茄子最大优势是自然成长，而且现订现摘，表皮手感略硬，非常新鲜。果肉细嫩，外皮薄，口感微甜，籽少。",
          },
          {
            type: :image,
            content: "description/茄子4.jpg",
          },
          {
            type: :text,
            content: "外观上，很明显的可以看出差别，本地的茄子像个黑富美，体型匀称，表皮相比市面上的普通茄子也更紫更亮。茄子皮的营养非常丰富，花青素含量很高，吃的时候不要削皮哦～",
          },
          {
            type: :text,
            content: "茄子在口感上也是差别比较细微的，普通大茄子肉厚比较适合烤茄子，普通线茄和本地茄子都比较适合做家常料理，选自己喜欢的就行，3种茄子元也生鲜均有售卖～",
          },
        ],
        [
          {
            type: :image,
            content: "description/青椒1.jpg",
          },
          {
            type: :image,
            content: "description/青椒2.jpg",
          },
          {
            type: :image,
            content: "description/青椒3.jpg",
          },
          {
            type: :text,
            content: "外观上，本地薄皮青椒要明显小于普通青椒，长的比较规则。虽然个头小，但是手感上略实沉。",
          },
          {
            type: :image,
            content: "description/青椒4.jpg",
          },
          {
            type: :text,
            content: "从剖面看，本地薄皮青椒白囊更少一些，其他差别不明显。气味上，本地青椒更浓郁一些。",
          },
        ],
        [
          {
            type: :image,
            content: "description/韭菜1.jpg",
          },
          {
            type: :image,
            content: "description/韭菜2.jpg",
          },
          {
            type: :text,
            content: "本地的小叶韭菜，区别于市面上的韭菜，叶子窄长，气味浓郁，口感鲜嫩，而且都是现订现割，更是新鲜好吃。",
          },
        ],
        [
          {
            type: :image,
            content: "description/苋菜1.jpg",
          },
          {
            type: :image,
            content: "description/苋菜2.jpg",
          },
          {
            type: :text,
            content: "本地红苋菜和市售红苋菜最大的区别在于，市售的是整颗红苋菜（连根部），本地的红苋菜只取苋菜头部最鲜嫩的部分进行售卖，因此口感更嫩水分更多！",
          },
        ]
      ]

      name.each_with_index do |n, index|
        Ingredient.find_by(name: n)&.update(description: data[index])
      end
    end
  end
end