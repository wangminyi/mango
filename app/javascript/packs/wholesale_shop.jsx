import React from 'react'
import ReactDOM from 'react-dom'
import { price_text } from '../helpers/wholesale_shop'

const CategoryList = (props) => {
  const categories = props.categories.map((category, index) => {
    const className = 'category-label' + (props.selectedCategory === category ? ' selected' : '')
    :class= {"category-label": true, "selected": props.selectedCategory === category}
    return (
      <div
        className = {className}
        onClick = {() => props.clickHandler(index)}
        key = {category.name}
      >
        {
          category.name
        }
      </div>
    )
  })
  return (
    <div className="categories-container">
      {categories}
    </div>
  )
}

const IngredientList = (props) => {
  if (!props.category) {
    return null;
  }

  const ingredients = props.category.items.map((item) => {
    return (
      <div className="ingredients-panel" key={item.id}>
        <div className="image-container">
          <img src={item.image} onClick={ null/* show pic */} />
        </div>
        <div className="ingredient-info-container">
          <div className="name-container">
            { item.name }
          </div>
          <div className="tag-container">
            {
              item.tags.map(tag => (
                <div className="tag" key={tag}>
                  { tag }
                </div>
              ))
            }
          </div>
          {
            item.texture && (
              <div className="texture">
                { item.texture }
              </div>
            )
          }
          <div className="price-container">
            <div className="price">
              { price_text(item.price) }
            </div>
            <div className="weight">
              { item.unit_text }
            </div>
          </div>
          <div className="operation-container">
            {
              item.count > 0 && (
                <div className="decrease" onClick={e => props.decrease_item_handler(item.id)}>
                  -
                </div>
              )
            }
            {
              item.count > 0 && (
                <div className="count">
                  { item.count }
                </div>
              )
            }
            <div className="increase" onClick={e => props.increase_item_handler(item.id)}>
              +
            </div>
          </div>
        </div>
      </div>
    )
  });

  return (
    <div className="ingredients-container">
      <div className="ingredients-list-container">
        {
          ingredients
        }
      </div>
    </div>
  )
}

const ShoppingFooter = (props) => {
  let empty = (
    <div className="shopping-cart-empty">
      <i className="fa fa-shopping-cart" />
      <span>购物车为空</span>
    </div>
  )

  let has_item = (
    <div className="shopping-cart">
      <div className="shopping-cart-container">
        <i className="fa fa-shopping-cart" />
        <span>{props.total_count}</span>
      </div>
      <div className="shopping-price-container">
        <div className="total-price">
          <span>{price_text(props.total_price)}</span>
        </div>
      </div>
      <div className="footer-btn">
        去结算
      </div>
    </div>
  )

  return (
    <div className="shopping-info-container page-footer">
      { props.total_count > 0 ? has_item : empty }
    </div>
  )
}

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      categories: []
    }
  }

  componentDidMount() {
    $.get("/shop/category_data", (data) => {
      this.setState({
        categories: data,
        selectedCategoryIndex: 0,
      })
    });
  }

  select_category_handler = (index) => {
    this.setState({
      selectedCategoryIndex: index
    });
  }

  decrease_item_handler = (item_id) => {
    let new_categories = [...this.state.categories]
    let item = new_categories[this.state.selectedCategoryIndex].items.find((item) => item.id === item_id)
    item.count -= 1

    this.setState({
      categories: new_categories
    })
  }

  increase_item_handler = (item_id) => {
    let new_categories = [...this.state.categories]
    let item = new_categories[this.state.selectedCategoryIndex].items.find((item) => item.id === item_id)
    item.count += 1

    this.setState({
      categories: new_categories
    })
  }

  render () {
    let total_count = 0,
        total_price = 0;
    this.state.categories.forEach(category => {
      category.items.forEach(item => {
        if (item.count > 0) {
          total_count += item.count
          total_price += item.count * item.price
        }
      })
    })

    return (
      <div className="yylife-wrapper">
        <div className="page-container shop-page-container">
          <div className="ingredients-container">
            <div className="goods-container">
              <div className="items-container">
                <CategoryList
                  clickHandler={this.select_category_handler}
                  categories={this.state.categories}
                  selectedCategory={this.state.selectedCategory}
                />
                <IngredientList
                  category={this.state.categories[this.state.selectedCategoryIndex]}
                  decrease_item_handler={this.decrease_item_handler}
                  increase_item_handler={this.increase_item_handler}
                />
              </div>
            </div>
          </div>
          <ShoppingFooter total_count={total_count} total_price={total_price}/>
        </div>
      </div>
    )
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App />,
    document.body.appendChild(document.createElement('div')),
  )
})
