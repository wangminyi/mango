//= require vue/dist/vue.min

$(function(){
  new Vue({
    el: "#shop-vue-anchor",
    template: "#shop-template",
    data: {
      selected_category: "蔬菜",
      categories: [
        {
          name: "蔬菜",
          ingredients: [
            {
              name: "小白菜",
              image: "http://i6.pdim.gs/7667ccffb013006e7b63a25edb15607d.jpeg"
            }
          ]
        }
      ]
    },
    computed: {
      selected_ingredients: function() {
        return this.categories.find(obj => obj.name === this.selected_category).ingredients
      }
    }
  })
})