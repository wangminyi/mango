//= require vue/dist/vue
//= require iview.min
//= require moment
//= require moment/locale/zh-cn

$(function(){
  // 微信 js 注册
  var wx_ready = false;
  wx.config(gon.js_config_params);
  wx.ready(function() {
    wx_ready = true;
  });

  moment.locale("zh-CN");
  var entries = gon.entries,
      addresses = gon.addresses;

  window.vue = new Vue({
    el: "#wholesale-vue-anchor",
    template: "#wholesale-template",
    data: {
      // 全局变量
      current_page: "entry", // 当前所在页面 entry detail order address edit_address
      // 弹出框
      confirm_params: {
        show: false,
        text: undefined,
        ok_callback: undefined,
        cancel_callback: undefined,
      },

      // 过渡相关
      slide_direction: "page-slide-right",

      // 入口页面
      selected_entry: undefined,
      entries: entries, // 商品对象

      // 拼团详情
      selected_instance: undefined,
      selected_item: undefined,
      buy_count: 1,

      // 订单页面
        // 表单字段slot
      selected_address: undefined, // 选择的地址 json
      selected_date: undefined, // 选择的送货日期 [今天，2017-4-6]
      selected_time: undefined, // 选择的送货时间 [16:00 ~ 18:00, "16:00"]
      coupon_enable: false,  // 是否使用优惠券
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
      editing_address: {
        id: undefined,
        name: undefined,
        gender: undefined,
        phone: undefined,
        garden: undefined,
        house_number: undefined,
        is_default: false,
      }, // 正在编辑的地址 json
      support_gardens: gon.settings.gardens,
    },
    computed: {
      // 选中类型的商品
      selected_items: function() {
        return this.selected_entry.items;
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
      address_text: function(addr) {
        return addr.name + "  " + addr.phone + "\n" + addr.garden + addr.house_number;
      },
      sales_volume_text: function(sales_volume) {
        return "月售" + sales_volume;
      }
    },
    methods: {
      select_entry: function(entry) {
        this.selected_entry = entry;
        this.forward_to("detail");
      },
      entry_price: function(entry) {
        return entry.min_price;
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
          $.cookie("cache_items", this.cookie_item_list);
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
        $.cookie("cache_items", this.cookie_item_list);
      },
      forward_to: function(page) {
        this.slide_direction = "page-slide-right";
        this.current_page = page;
      },
      back_to: function(page) {
        this.slide_direction = "page-slide-left";
        this.current_page = page;
      },

      // 可选择日期 @Array [label, value]
      selectable_date: function() {
        var result = [],
            hour = moment().hour();
        if (hour < 14) {
          result.push(
            [
              "今天",
              moment().format("YYYY-MM-DD")
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
              i + ":00 ~ " + (i + 1) + ":00 (下午)",
              time.hour(i).minute(0).format("H:mm")
            ]
          );
        }

        if ("今天" !== this.temp_selected_date[0] || now.hour() < 8) {
          // 次日送达 或 今日送达且当前时间小于8点
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
        $.each(this.editing_address, function(attr){
          that.editing_address[attr] = address[attr];
        });

        this.forward_to("edit_address");
      },
      delete_address: function(address) {
        this.show_confirm_dialog({
          text: "您确定要删除该地址？",
          ok: function() {
            var that = this;
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
              that.show_confirm_dialog({
                text: "操作失败"
              });
            })
          },
          cancel: true
        });
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
        $.each(this.editing_address, function(attr){
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
            url = (this.editing_address.id === undefined ? "/addresses/create" : "/addresses/update");
        $.post(url, {
          address_id: this.editing_address.id,
          address: this.editing_address,
        }).done(function(data){
          that.address_info = data.addresses;
          that.back_to("address");
        }).fail(function(data){
          var msg;
          if (data.status === 422) {
            msg = data.responseJSON.error;
          } else {
            msg = "操作失败";
          }
          that.show_confirm_dialog({
            text: msg
          });
        }).always(function(){
          that.submitting_address = false;
        })
      },
      submit_order: function() {
        if (this.selected_address === undefined) {
          this.show_confirm_dialog({
            text: "请选择送货地址"
          });
        } else if (this.selected_date_time_value === undefined) {
          this.show_confirm_dialog({
            text: "请选择送货时间"
          });
        } else {
          var that = this;
          this.show_confirm_dialog({
            text: "确定提交订单吗？",
            ok: function() {
              var addr = this.selected_address,
              item_list = JSON.stringify($.map(this.shopping_cart_list, function(item) {
                return {
                  id: item.id,
                  count: item.count,
                };
              }));
              $.post("/orders", {
                order: {
                  item_list: item_list,
                  gifts: JSON.stringify(this.gift_list),
                  item_price: this.total_price, // 商品总价
                  total_price: this.order_price, // 订单总价 double check
                  distribute_at: this.selected_date_time_value,
                  distribution_price: this.distribute_price,
                  free_distribution_reason: this.free_distribution_reason,
                  preferential_price: this.coupon_enable ? this.preferential_price : 0,
                  receiver_name: addr.name,
                  receiver_phone: addr.phone,
                  receiver_garden: addr.garden,
                  receiver_address: addr.garden + addr.house_number,
                  remark: this.remark,
                }
              }).done(function(data) {
                if (wx_ready) {
                  var params = data.pay_params,
                      order_url = data.order_url;
                  params.success = function() {
                    that.show_confirm_dialog({
                      text: "支付成功",
                      ok: function() {
                        $.removeCookie("cache_items");
                        window.location = order_url + "?from=shop";
                      }
                    });
                  }
                  wx.chooseWXPay(params);
                }
              }).fail(function() {
                that.show_confirm_dialog({
                  text: "订单提交失败",
                })
              }).always(function() {

              });
            },
            cancel: true
          })
        }
      },
      // 弹框
      show_confirm_dialog: function (options) {
        this.confirm_params = {
          text: options.text,
          ok_callback: options.ok,
          cancel_callback: options.cancel,
          show: true
        }
      },
      confirm_cancel: function () {
        this.confirm_params.show = false;
        if (typeof this.confirm_params.cancel_callback === "function") {
          this.confirm_params.cancel_callback();
        }
      },
      confirm_ok: function () {
        this.confirm_params.show = false;
        if (typeof this.confirm_params.ok_callback === "function") {
          this.confirm_params.ok_callback.apply(this);
        }
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
    }
  });
})