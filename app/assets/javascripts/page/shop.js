//= require vue/dist/vue.min
//= require moment
//= require moment/locale/zh-cn

$(function(){
  moment.locale("zh-CN");
  Vue.config.devtools = true;

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

  window.vue = new Vue({
    el: "#shop-vue-anchor",
    template: "#shop-template",
    data: {
      // 全局变量
      order_type: "today", // 今日送货 today 预订送货 schedule
      free_distribution: 1000, // 满减金额
      current_page: "order", // 当前所在页面 shopping order address
      can_immediately: true, // 能否可以立即送

      // 过渡相关
      slide_direction: "slide-right",

      // 购物页面
      selected_category: categories[0], // 选中的商品类别
      show_shopping_cart: false, // 购物页面是否显示购物车详情
      show_header_hint: ($.cookie("show_header_hint") === undefined), // 是否显示顶部提示
      categories: categories, // 商品对象

      // 订单页面
      selected_address: undefined, // 选择的地址
      selected_date: undefined, // 选择的送货日期 2017-04-06
      selected_time: undefined, // 选择的送货时间 16:00
      temp_selected_date: undefined,
      temp_selected_time: undefined,
      show_time_selector: false,

      // 地址页面
      support_gardens: [ // 支持的小区名称
        "周浦印象春城",
        "周浦逸亭佳苑",
        "周浦兰亭-九龙仓",
        "周浦惠康公寓",
      ],
      address_info: [
        {
          id: 1,
          name: "一二三",
          gender: "female",
          phone: "13888888888",
          garden: "周浦印象春城",
          house_number: "72幢301",
          is_default: false,
        },
        {
          id: 2,
          name: "四五六",
          gender: "female",
          phone: "13666666688",
          garden: "周浦逸亭佳苑",
          house_number: "27幢101",
          is_default: false,
        }
      ],
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
      },
      selected_date_time_text: function() {
        if (this.selected_date !== undefined && this.selected_time !== undefined) {
          if (this.selected_date[1] === moment().format("YYYY-MM-DD")) {
            // 当天
            return this.selected_time[0];
          } else {
            return this.selected_date[0] + " " + this.selected_time[0];
          }
        } else {
          return undefined;
        }
      },
      selected_date_time_value: function() {
        if (this.selected_date !== undefined && this.selected_time !== undefined) {
          return this.selected_date[1] + " " + this.selected_time[1];
        } else {
          return undefined;
        }
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
      },
      address_text: function(addr) {
        return addr.name + "  " + addr.phone + "\n" + addr.garden + addr.house_number;
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
      },
      forward_to: function(page) {
        this.slide_direction = "slide-right";
        this.current_page = page;
      },
      back_to: function(page) {
        this.slide_direction = "slide-left";
        this.current_page = page;
      },
      selectable_date: function() {
        var result = [],
            date  = moment();
        if (this.order_type === "today") {
          result.push(
            [
              "今天",
              date.format("YYYY-MM-DD")
            ]
          );
        } else {
          var text_hash = ["明天", "后天"];
          for (var i = 0 ; i < 2 ; i += 1) {
            date.add(1, "d")
            result.push(
              [
                text_hash[i] + "(" + date.format("M.D") + ")",
                date.format("YYYY-MM-DD")
              ]
            )
          }
        }

        return result;
      },
      selectable_time: function() {
        if (this.temp_selected_date === undefined) {
          return [];
        }

        var result = [],
            time   = moment(),
            hour = time.hour(),
            from_hour,
            to_hour = 18;
        // 如选择今日送货，且有立即送额度，且在配送时间内，则显示立即送选项
        if (this.order_type === "today") {
          from_hour = Math.max((hour + 2 - hour % 2), 8);
          if (this.can_immediately && from_hour > 8) {
            result.push(
              [
                "立即送 (1小时以内)",
                "immediately"
              ]
            )
          }
        } else {
          from_hour = 8;
        }

        for(var i = from_hour ; i <= to_hour ; i += 2 ) {
          var time_period;
          if (i <= 10) {
            time_period = "上午";
          } else if (i <= 16 ) {
            time_period = "下午";
          } else {
            time_period = "傍晚";
          }

          result.push(
            [
              i + ":00 ~ " + (i + 2) + ":00 (" + time_period + ")",
              time.hour(i).minute(0).format("H:mm"),
            ]
          );
        }

        return result;
      },
      date_selected: function(date) {
        return this.temp_selected_date !== undefined && this.temp_selected_date[0] === date[0];
      },
      time_selected: function(time) {
        return this.temp_selected_time !== undefined && this.temp_selected_time[0] === time[0];
      },
      date_option_handler: function(_selected_date) {
        if (!this.date_selected(_selected_date)) {
          this.temp_selected_date = _selected_date;
          this.temp_selected_time = undefined;
        }
      },
      time_option_handler: function(_selected_time) {
        if (!this.time_selected(_selected_time)) {
          this.temp_selected_time = _selected_time;
        }
      },
      cancel_time_handler: function() {
        this.selected_date = this.selected_date;
        this.selected_time = this.selected_time;
        this.show_time_selector = false;
      },
      submit_time_handler: function() {
        this.selected_date = this.temp_selected_date;
        this.selected_time = this.temp_selected_time;
        this.show_time_selector = false;
      }
    },
    mounted: function () {
      var default_addr = undefined;
      $.each(this.address_info, function(index, addr) {
        if (addr.is_default) {
          default_addr = addr;
        }
      });
      this.selected_address = default_addr;
    }
  })
})