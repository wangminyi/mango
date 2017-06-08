//= require vue/dist/vue.min
//= require moment
//= require moment/locale/zh-cn

$(function(){
  moment.locale("zh-CN");
  Vue.config.devtools = true;
  var categories = gon.categories,
      addresses = gon.addresses;

  window.vue = new Vue({
    el: "#shop-vue-anchor",
    template: "#shop-template",
    data: {
      // 全局变量
      distribution_price: gon.settings.distribution_price, // 配送费
      free_distribution: gon.settings.free_distribution, // 免配送费金额
      current_page: "shopping", // 当前所在页面 shopping order address edit_address
      // can_immediately: false, // 能否可以立即送
      preferential_price: gon.settings.preferential_price, // 优惠金额

      // 过渡相关
      slide_direction: "slide-right",

      // 购物页面
      selected_category: categories[0], // 选中的商品类别
      show_shopping_cart: false, // 购物页面是否显示购物车详情
      selected_description: undefined,  // 显示做法
      show_header_hint: ($.cookie("show_header_hint") === undefined), // 是否显示顶部提示
      categories: categories, // 商品对象
      gifts: gon.gifts,

      // 订单页面
        // 表单字段slot
      selected_address: undefined, // 选择的地址 json
      selected_date: undefined, // 选择的送货日期 [今天，2017-4-6]
      selected_time: undefined, // 选择的送货时间 [16:00 ~ 18:00, "16:00"]
      coupon_enable: true,  // 是否使用优惠券
      // pay_mode: "cod", // cod(cash on delivery) || wechat
      remark: undefined, // 备注
        // 局部变量
      temp_selected_date: undefined, // 选择控件的日期值 [今天，2017-4-6]
      temp_selected_time: undefined, // 选择控件的时间值 [16:00 ~ 18:00, "16:00"]
      show_time_selector: false, // 是否显示时间控件

      address_info: addresses,

      // 编辑地址页面
      show_garden_selector: false,
      submitting_address: false,
      address_attributes: [
        "id",
        "name",
        "gender",
        "phone",
        "garden",
        "house_number",
        "is_default",
      ],
      editing_address: {
        id: undefined,
        name: undefined,
        gender: undefined,
        phone: undefined,
        garden: undefined,
        house_number: undefined,
        is_default: false,
      }, // 正在编辑的地址 json
      support_gardens: [ // 支持的小区名称
        "周浦印象春城",
        "周浦逸亭佳苑",
        "周浦兰亭-九龙仓",
        "周浦惠康公寓",
      ],
    },
    computed: {
      // 选中类型的商品
      selected_items: function() {
        if (this.selected_category === this.gifts) {
          return this.gifts;
        } else {
          return this.selected_category.items;
        }
      },
      // 所有食材对象的hash
      items_hash: function(){
        var hash = {};
        $.each(this.categories, function(index, category) {
          $.each(category.items, function(index, item) {
            hash[item.id] = item;
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
        var price = 0,
            that  = this;
        $.each(this.shopping_cart_list, function(index, item) {
          price += item.count * that.item_price(item);
        });
        return price;
      },
      // 赠品计算逻辑
      gift_list: function(){
        var result = [],
            that = this;
        $.each(this.gifts, function(index, gift) {
          if (that.total_price >= gift.limit) {
            result.push(gift);
          }
        });
        return result;
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
      },
      // 免运费原因
      free_distribution_reason: function() {
        if (this.total_price >= this.free_distribution) {
          return "满10元免配送费";
        }
        // else if (this.can_immediately) {
        //   return "会员权益";
        // }
      },
      distribute_price: function() {
        if (this.free_distribution_reason) {
          return 0;
        } else {
          return this.distribution_price;
        }
      },
      order_price: function() {
        var result = this.total_price + this.distribute_price;

        if (this.coupon_enable) {
          result -= this.preferential_price;
        }
        return Math.max( result, 0 );
      }
    },
    filters: {
      price_text: function(price) {
        return "￥" + (price / 100).toFixed(2);
      },
      weight_text: function(item) {
        return "/ " + item.weight + item.unit;
      },
      address_text: function(addr) {
        return addr.name + "  " + addr.phone + "\n" + addr.garden + addr.house_number;
      }
    },
    methods: {
      change_category: function(category) {
        this.selected_category = category;
        $(".ingredients-container").scrollTop(0);
      },
      // 展示详情
      show_description: function(item) {
        this.selected_description = item.description;
      },
      add_dish: function(dish, e) {
        var that = this;
        add_to_shopping_cart(e);
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
      item_price: function(item) {
        return item.price;
      },
      can_increase: function(item, number) {
        var result_count = item.count + (number || 1);
        return result_count <= (item.order_limit || 100);
      },
      increase_item: function(item, number) {
        number = number || 1;
        // xx份起卖
        if ($.isNumeric(item.limit_count) && item.limit_count > item.count + number) {
          number = item.limit_count;
        }
        if (this.can_increase(item, number)) {
          item.count += number;
        }
      },
      decrease_item: function(item, number) {
        number = number || 1;
        if (item.count >= number) {
          item.count -= number;
        }
        if (item.count < item.limit_count) {
          item.count = 0;
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

      // 可选择日期 @Array [label, value]
      selectable_date: function() {
        var result = [],
            hour = moment().hour();
        if (hour < 13) {
          result.push(
            [
              "今天",
              date.format("YYYY-MM-DD")
            ]
          );
        }

        result.push(
          [
            "明天",
            moment().add(1, "d").format("YYYY-MM-DD")
          ]
        );

        return result;
      },

      // 可选择时间 @Array [label, value]
      selectable_time: function() {
        if (this.temp_selected_date === undefined) {
          return [];
        }

        var result = [],
            time = moment(),
            now = moment(),
            morning_slot = [],
            afternoon_slot = [];

        // 上午
        for(var i = 9 ; i < 11 ; i += 1) {
          morning_slot.push(
            [
              i + ":00 ~ " + (i + 1) + ":00 (上午)",
              time.hour(i).minute(0).format("H:mm")
            ]
          );
        }

        // 下午
        for(var i = 16 ; i < 19 ; i += 1) {
          afternoon_slot.push(
            [
              i + ":00 ~ " + (i + 1) + ":00 (上午)",
              time.hour(i).minute(0).format("H:mm")
            ]
          );
        }

        if (now.format("YYYY-MM-DD") !== this.temp_selected_date && now.hour() < 20) {
          // 次日送达 且 当前时间8点之前
          result = morning_slot.concat(afternoon_slot);
        } else {
          result = afternoon_slot;
        }
        return result;
      },
      // 是否选择了某日期
      date_selected: function(date) {
        return this.temp_selected_date !== undefined && this.temp_selected_date[0] === date[0];
      },
      // 是否选择了某时间
      time_selected: function(time) {
        return this.temp_selected_time !== undefined && this.temp_selected_time[0] === time[0];
      },
      // 处理选择日期事件
      date_option_handler: function(_selected_date) {
        if (!this.date_selected(_selected_date)) {
          this.temp_selected_date = _selected_date;
          this.temp_selected_time = undefined;
        }
      },
      // 处理选择时间事件
      time_option_handler: function(_selected_time) {
        if (!this.time_selected(_selected_time)) {
          this.temp_selected_time = _selected_time;
        }
      },
      // 取消选择
      cancel_time_handler: function() {
        this.temp_selected_date = this.selected_date;
        this.temp_selected_time = this.selected_time;
        this.show_time_selector = false;
      },
      // 确认选择
      submit_time_handler: function() {
        this.selected_date = this.temp_selected_date;
        this.selected_time = this.temp_selected_time;
        this.show_time_selector = false;
      },

      // ====== 地址列表 ======
      select_address: function(address) {
        this.selected_address = address;
        this.back_to("order");
      },
      edit_address: function(address) {
        var that = this;
        $.each(this.address_attributes, function(index, attr){
          that.editing_address[attr] = address[attr];
        });

        this.forward_to("edit_address");
      },
      delete_address: function(address) {
        var that = this;
        if(confirm("您确定要删除该地址？")){
          $.post("/addresses/destroy", {
            address_id: address.id
          }).done(function(){
            if ((index = that.address_info.indexOf(address)) >= 0) {
              that.address_info.splice(index, 1);
              if (that.selected_address === address) {
                that.selected_address = undefined;
              }
            }
          }).fail(function(){
            alert("操作失败");
          })
        }
      },
      add_address: function() {
        var that = this;
        this.clear_editing_address();
        this.forward_to("edit_address");
      },

      // ====== 编辑地址 ======
      select_garden_handler: function(garden) {
        this.editing_address.garden = garden;
        this.show_garden_selector = false;
      },

      clear_editing_address: function() {
        var that = this;
        $.each(this.address_attributes, function(index, attr){
          if(typeof that.editing_address[attr] === "boolean") {
            that.editing_address[attr] = false;
          }else{
            that.editing_address[attr] = undefined;
          }
        })
      },
      submit_address: function() {
        if (this.submitting_address) {
          return;
        } else {
          this.submitting_address = true;
        }
        var that = this,
            url = (this.editing_address.id === undefined ? "addresses/create" : "addresses/update");
        $.post(url, {
          address_id: this.editing_address.id,
          address: this.editing_address,
        }).done(function(data){
          that.address_info = data.addresses;
          that.back_to("address");
        }).fail(function(){
          alert("地址信息不完整");
        }).always(function(){
          that.submitting_address = false;
        })
      },
      submit_order: function() {
        var addr = this.selected_address,
            item_details = $.map(this.shopping_cart_list, function(item) {
              return {
                id: item.id,
                count: item.count,
              };
            });
        $.post("/orders/create", {
          order: {
            item_details: JSON.stringify(item_details),
            item_price: this.total_price, // 商品总价
            coupon_enable: this.coupon_enable, // 是否优惠
            total_price: this.order_price, // 订单总价 double check
            // pay_mode: this.paymode,
            distribute_at: this.selected_date_time_value,
            distribution_price: this.distribute_price,
            free_distribution_reason: this.free_distribution_reason,
            preferential_price: this.preferential_price,
            receiver_name: addr.name,
            receiver_phone: addr.phone,
            receiver_address: addr.garden + addr.house_number,
            remark: this.remark,
          }
        }).done(function() {

        }).fail(function() {

        }).always(function() {

        });
      }
    },
    mounted: function () {
      // 设置默认地址
      var default_addr = undefined;
      $.each(this.address_info, function(index, addr) {
        if (addr.is_default) {
          default_addr = addr;
        }
      });
      this.selected_address = default_addr;

      // 设置默认送货日期
      this.temp_selected_date = this.selectable_date()[0];
    }
  });

  function add_to_shopping_cart(event) {
    var from_x = event.clientX - 10,
        from_y = event.clientY - 10,
        $target = $(".fa-shopping-cart"),
        to_x   = $target.offset().left,
        to_y   = $target.offset().top,
        $ele   = $("<div class='throwable-ball'></div>").appendTo($("body"));
    $ele.css({
      left: from_x,
      top: from_y,
    }).animate({
      left: to_x,
      top: to_y,
    }, {
      duration: 500,
      complete: function(){
        $ele.remove();
      },
    });
  }
})