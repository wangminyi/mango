//= require vue/dist/vue.min

$(function(){
  var categories = [
    {
      name: "每日推荐",
      items: [
        {
          name: "糖醋排骨",
          type: "dish",
          image: "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg",
          label: "所需食材：猪小排、生姜",
          price: 2850,
          items: [
            {
              id: 1,
              count: 1,
            },
            {
              id: 5,
              count: 2,
            }
          ]
        }
      ]
    },
    {
      name: "蔬菜",
      items: [
        {
          id: 1,
          name: "小白菜",
          type: "ingredient",
          image: "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg",
          label: "推荐食谱：蒜蓉青菜、香菇青菜、百叶青菜",
          discount: true,
          price: 350,
          weight: 500,
          count: 1,
          texture: "口感不错"
        },{
          id: 2,
          name: "小白菜",
          image: "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg",
          type: "ingredient",
          relate_dishes: ["蒜蓉青菜", "香菇青菜", "百叶青菜"],
          discount: true,
          price: 350,
          weight: 500,
          count: 0,
        },{
          id: 3,
          name: "小白菜",
          type: "ingredient",
          image: "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg",
          relate_dishes: ["蒜蓉青菜", "香菇青菜", "百叶青菜"],
          discount: true,
          price: 350,
          weight: 500,
          count: 0,
        },{
          id: 4,
          name: "小白菜",
          type: "ingredient",
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
      items: [
        {
          id: 5,
          name: "猪肉",
          type: "ingredient",
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
      unsellable: true,
      unsellhint: "水产品价格每日变动较大，且为保证鲜活，仅支持微信预订和货到付款，望谅解。\n加店主微信（Sthaboutlinda）预订，送货上门。",
      items: [
        {
          id: 6,
          name: "龙虾",
          type: "ingredient",
          image: "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg",
          relate_dishes: ["蒜蓉青菜", "香菇青菜", "百叶青菜"],
          discount: true,
          price: 5000,
          weight: 500,
          count: 0,
        }
      ]
    }
  ];

  new Vue({
    el: "#shop-vue-anchor",
    template: "#shop-template",
    data: {
      order_type: "immediately",
      selected_category: categories[0],
      free_distribution: 1000,
      show_shopping_cart: false,
      show_header_hint: ($.cookie("show_header_hint") === undefined),
      categories: categories,
    },
    computed: {
      // 选中类型的商品
      selected_items: function() {
        return this.selected_category.items;
      },
      // 所有食材对象的hash
      items_hash: function(){
        var hash = {};
        $.each(this.categories, function(index, category) {
          $.each(category.items, function(index, item) {
            if (item.type === "ingredient") {
              hash[item.id] = item;
            }
          })
        });
        return hash;
      },
      // 选购的商品
      shopping_cart_list: function() {
        var buy_items = [];
        $.each(this.items_hash, function(id, item) {
          if (item.count > 0) {
            buy_items.push(item);
          }
        });
        return buy_items;
      },
      // 选购商品的总数
      total_count: function(){
        var count = 0;
        $.each(this.shopping_cart_list, function(index, item) {
          count += item.count;
        });
        return count;
      },
      // 选购商品的总价
      total_price: function(){
        var price = 0;
        $.each(this.shopping_cart_list, function(index, item) {
          price += item.count * item.price;
        });
        return price;
      }
    },
    filters: {
      price_text: function(price) {
        return "￥" + (price / 100).toFixed(2);
      },
      weight_text: function(weight) {
        return "/ 约" + weight + "g";
      },
      unsellable_text: function(item) {
        return "(约￥" + (item.price / 100) + "/" + item.weight + "g)";
      }
    },
    methods: {
      add_dish: function(dish) {
        var that = this;
        $.each(dish.items, function(index, item) {
          that.increase_item(that.items_hash[item.id], item.count);
        })
      },
      category_count: function(category) {
        var sum = 0;
        $.each(category.items, function(index, item){
          if ($.isNumeric(item.count)) {
            sum += item.count;
          }
        });
        return sum;
      },
      clear_shopping_cart: function() {
        if (confirm("清空购物车中所有商品？")) {
          $.each(this.shopping_cart_list, function(index, item){
            item.count = 0;
          });
          this.show_shopping_cart = false;
        }
      },
      increase_item: function(item, number) {
        number = number || 1;
        item.count += number;
      },
      decrease_item: function(item, number) {
        number = number || 1;
        if (item.count >= number) {
          item.count -= number;
        }
        if (this.shopping_cart_list.length === 0) {
          this.show_shopping_cart = false;
        }
      },
      hide_header_hint: function(){
        this.show_header_hint = false;
        $.cookie("show_header_hint", true);
      }
    }
  })
})