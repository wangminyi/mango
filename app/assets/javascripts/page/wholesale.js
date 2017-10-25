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
  var weekday_name = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"],
      entries = gon.entries;

  test_data = {
    // selected_entry: entries[0],
    // show_entry_form: true,
    // selected_instance: entries[0].instances[0],
    // selected_item: entries[0].items[0],
    // buy_count: 1,
    // current_page: "detail",
  }

  window.vue = new Vue({
    el: "#wholesale-vue-anchor",
    template: "#wholesale-template",
    data: $.extend({
      // 全局变量
      current_page: "entry", // 当前所在页面 entry detail order address edit_address
      pending: false, // loading
      // 过渡相关
      slide_direction: "page-slide-right",

      // 入口页面
      selected_entry: undefined,
      entries: entries, // 商品对象

      // 拼团详情
      show_entry_form: false,
      instances: [],
      selected_instance: undefined, // 选择的批次
      selected_item: undefined, // 选购的产品
      buy_count: 1, // 购买数量
      show_share_hint: false,

      // 订单页面
        // 表单字段slot
      //selected_address => mixins
      selected_date: undefined, // 选择的送货日期 [今天，2017-4-6]
      selected_time: undefined, // 选择的送货时间 [16:00 ~ 18:00, "16:00"]
      coupon_enable: false,  // 是否使用优惠券
      // pay_mode: "cod", // cod(cash on delivery) || wechat
      remark: undefined, // 备注
        // 局部变量
      temp_selected_date: undefined, // 选择控件的日期值 [今天，2017-4-6]
      temp_selected_time: undefined, // 选择控件的时间值 [16:00 ~ 18:00, "16:00"]
      show_time_selector: false, // 是否显示时间控件
    }, test_data),
    computed: {
      // 选购商品的总价
      total_price: function(){
        if (this.selected_item === undefined) {
          return 0;
        } else {
          return this.buy_count * this.selected_item.price;
        }
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
      order_price: function() {
        return this.total_price;
      }
    },
    methods: {
      select_entry: function(entry) {
        var that = this;
        this.pending_timeout_id = setTimeout(function(){
          that.pending = true
        }, 500);

        $.get("wholesale_instances", {
          id: entry.id,
        }).done(function(data){
          that.selected_entry = entry;
          that.instances = data.instances;
          that.selected_instance = data.instances[0];
          that.select_item(entry.items[0]);
          that.forward_to("detail");
        }).always(function(){
          clearTimeout(that.pending_timeout_id);
          that.pending = false;
        });
      },
      select_item: function(item) {
        this.selected_item = item;
        this.buy_count = item.limit_count;
      },
      entry_price: function(entry) {
        return entry.min_price;
      },
      increase_count: function() {
        this.buy_count += 1;
        this.buy_count = Math.max(this.buy_count, this.selected_item.limit_count)
      },
      decrease_count: function() {
        this.buy_count -= 1;
        this.buy_count = Math.max(this.buy_count, this.selected_item.limit_count)
      },
      go_to_order: function() {
        if (this.selected_entry !== undefined && this.selected_instance !== undefined && this.selected_item !== undefined && this.buy_count > 0) {
          this.forward_to('order');
        } else {
          this.show_confirm_dialog({
            text: "请选择您要参加的团和购买的数量"
          });
        }
      },
      forward_to: function(page) {
        this.slide_direction = "page-slide-right";
        this.current_page = page;
      },
      back_to: function(page) {
        this.slide_direction = "page-slide-left";
        this.current_page = page;
      },

      open_time_selector: function() {
        this.show_time_selector = true;
        if (this.temp_selected_date === undefined) {
          this.temp_selected_date = this.selectable_date()[0];
        }
      },
      // 可选择日期 @Array [label, value]
      selectable_date: function() {
        var result = [],
            from = moment(this.selected_instance.distribute_date_from),
            to = moment(this.selected_instance.distribute_date_to);
        while (from <= to) {
          result.push(
            [
              from.format("MM") + "月" + from.format("DD") + "日 " + weekday_name[from.weekday()],
              from.format("YYYY-MM-DD")
            ]
          );
          from.add(1, "d");
        }

        return result;
      },

      // 可选择时间 @Array [label, value]
      selectable_time: function() {
        if (this.temp_selected_date === undefined) {
          return [];
        }

        var morning_slot = [],
            afternoon_slot = [],
            time = moment();

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

        if (this.selected_instance.distribute_scope === "morning") {
          return morning_slot;
        } else if (this.selected_instance.distribute_scope === "afternoon") {
          return afternoon_slot;
        } else {
          return morning_slot.concat(afternoon_slot);
        }
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
              $.post("/wholesale_orders", {
                order: {
                  wholesale_instance_id: this.selected_instance.id,
                  wholesale_item_id: this.selected_item.id,
                  item_count: this.buy_count,
                  item_price: this.total_price, // 商品总价
                  total_price: this.order_price, // 订单总价 double check
                  preferential_price: 0,
                  distribute_at: this.selected_date_time_value,
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
    },
    mixins: [window.mixins["address"], window.mixins["utils"]],
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
