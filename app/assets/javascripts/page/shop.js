//= require vue/dist/vue.min

$(function(){
  new Vue({
    el: "#shop-vue-anchor",
    template: "#shop-template",
    data: {
      order_type: "immediately",
      selected_category: "蔬菜",
      categories: [
        {
          name: "蔬菜",
          ingredients: [
            {
              name: "小白菜",
              image: "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg",
              relate_dishes: ["蒜蓉青菜", "香菇青菜", "百叶青菜"],
              discount: true,
              price: 350,
              weight: 500,
              count: 0,
            }
          ]
        },
        {
          name: "肉禽",
          ingredients: [
            {
              name: "猪肉",
              image: "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg",
              relate_dishes: ["A", "B", "C"],
              discount: false,
              price: 350,
              weight: 500,
              count: 0,
            }
          ]
        },
        {
          name: "水产",
          ingredients: [
            {
              name: "龙虾",
              image: "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg",
              relate_dishes: ["蒜蓉青菜", "香菇青菜", "百叶青菜"],
              discount: true,
              price: 350,
              weight: 500,
              count: 0,
            }
          ]
        }
      ]
    },
    computed: {
      selected_ingredients: function() {
        return this.categories.find(obj => obj.name === this.selected_category).ingredients
      },
      total_count: function(){
        var count = 0;
        $.each(this.categories, function(index, category) {
          $.each(category.ingredients, function(index, ingredient) {
            count += ingredient.count;
          })
        });
        return count;
      },
      total_price: function(){
        var price = 0;
        $.each(this.categories, function(index, category) {
          $.each(category.ingredients, function(index, ingredient) {
            price += ingredient.count * ingredient.price;
          })
        });

        return price;
      }
    },
    filters: {
      relate_dishes_text: function(dishes){
        return "推荐食谱：" + dishes.join("、");
      },
      price_text: function(price) {
        return "￥" + (price / 100).toFixed(2);
      },
      weight_text: function(weight) {
        return "/ 约" + weight + "g";
      }
    }
  })
})