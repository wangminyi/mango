$(function(){
  window.mixins = {};
  window.mixins["utils"] = {
    data: {
      // 弹出框
      confirm_params: {
        show: false,
        text: undefined,
        ok_callback: undefined,
        cancel_callback: undefined,
      },
    },
    filters: {
      price_text: function(price) {
        return "￥" + (price / 100).toFixed(2);
      },
      address_text: function(addr) {
        return addr.name + "  " + addr.phone + "\n" + addr.garden + addr.house_number;
      },
    },
    methods: {
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
    }
  };

  window.mixins["address"] = {
    data: {
      selected_address: undefined, // 选择的地址 json
      address_info: gon.addresses,
      // 编辑地址页面
      submitting_address: false,
      garden_keyword: "",
      editing_address: {
        id: undefined,
        name: undefined,
        gender: undefined,
        phone: undefined,
        garden: undefined,
        house_number: undefined,
        is_default: false,
      }, // 正在编辑的地址 json
      // support_gardens: gon.settings.gardens,
      support_gardens: gon.settings.new_gardens,
    },

    computed: {
      grouped_gardens: function() {
        var result = {},
            keyword = this.garden_keyword;
        $.each(this.support_gardens, function(index, garden) {
          if (this.match_garden(garden, keyword)) {
            var first_letter = garden.first_letters[0].toUpperCase();
            result[first_letter] = result[first_letter] || [];
            result[first_letter].push(garden.name);
          }
        }.bind(this))
        return result;
      }
    },
    methods: {
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
      // 选择小区
      match_garden: function (garden, keyword) {
        if (keyword === "") {
          return true;
        } else {
          // name chars first-letter
          return garden.name.indexOf(keyword) >= 0 || garden.chars.indexOf(keyword) >= 0 || garden.first_letters.indexOf(keyword) >= 0;
        }
      },
      select_garden_handler: function(garden) {
        this.editing_address.garden = garden;
        this.back_to("edit_address");
      },
    }
  }
})
