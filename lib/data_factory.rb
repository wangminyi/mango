class DataFactory
  require "csv"

  class << self
    def init_categories
      %w(蔬菜类 豆制品 肉禽类 水产类 配料).each do |name|
        Category.find_or_create_by(name: name)
      end
    end

    def import_ingredient
      CSV.foreach("./data_files/ingredients.csv") do |line|
        Ingredient.create(
          name: line[0],
        )
      end
    end

    def import_dishes
      CSV.foreach("./data_files/dishes.csv") do |line|
        dish = Dish.create(
          name: line[0],
        )
        line.reject(&:blank?)[1..-1].each do |ingredient|
          i = Ingredient.find_by(name: ingredient)
          dish.ingredients << i if i.present?
        end
      end
    end

    def import_cooking_method
      CSV.foreach("./data_files/methods.csv") do |line|
        dish = Dish.find_by(name: line[0])&.update(cooking_method: line[1])
      end
    end

    def import_categories
      {
        1 => 1..61,
        2 => 69..79,
        3 => 80..99,
        4 => 100..117,
        5 => 62..68,
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
      Ingredient.preload(:category).all.each do |ingredient|
        relative_path = "ingredients/#{ingredient.category.name}/#{ingredient.name}.jpg"
        file = File.join(dir_path, relative_path)
        if File.exists? file
          ingredient.update_attribute(:image, relative_path)
        end
      end
    end
  end
end