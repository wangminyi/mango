class DataFactory
  require "csv"

  class << self
    def init_categories
      %w(蔬菜类 豆制品 肉禽类 水产类 配料).each do |name|
        Category.find_or_create_by(name: name)
      end
    end

    def import_data
      Ingredient.delete_all
      Dish.delete_all
      DishesIngredient.delete_all
      import_ingredient
      import_ingredients_img
      import_dishes
      import_cooking_method
    end

    def import_ingredient
      CSV.foreach("./data_files/ingredients.csv") do |line|
        Ingredient.create(
          name: line[0],
        )
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

    def import_categories
      {
        1 => 258..332,
        2 => 333..342,
        3 => 344..364,
        4 => 365..385,
        5 => 386..397,
      }.each do |category_id, ingredient_ids|
        Ingredient.where(id: ingredient_ids).update_all(category_id: category_id)
      end
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

    def import_ingredients_img
      dir_path = File.join(Rails.root + "app/assets/images")
      suffixes = ["jpg", "jpeg"]
      undefined_ingredients = []
      Ingredient.where(image: nil).each do |ingredient|
        relative_path = nil
        suffixes.each do |suffix|
          temp_path = "ingredients/#{ingredient.name}.#{suffix}"
          file = File.join(dir_path, temp_path)
          if File.exists? file
            relative_path = temp_path
            break
          end
        end

        if relative_path.present?
          ingredient.update_attribute(:image, relative_path)
        else
          undefined_ingredients << ingredient.name
        end
      end

      puts undefined_ingredients.join(",")
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
  end
end