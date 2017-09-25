// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

function FunctionalComponent () {
  function simple_handler () {
    console.log(new Date());
  }

  return (
    <div onClick={simple_handler}>
      test
    </div>
  )
}

class Hello extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      index: 1,
      show: true,
    }

    // this.change_index = this.change_index.bind(this)
  }

  componentDidMount() {
    // setInterval(() => {
    //   this.setState({
    //     index: (this.state.index + 1) % this.props.name.length
    //   })
    // }, 1000)
  }

  change_index = () => {
    this.setState({
      index: (this.state.index + 1) % this.props.name.length
    })
  }

  toggle_show = () => {
    this.setState({
      show: !this.state.show
    })
  }

  render () {
    return (
      <div onClick={this.toggle_show}>
        {
          this.state.show ? "Hello" + this.props.name[this.state.index] + "!" : 'hide'
        }
      </div>
    )
  }
}


// const Hello = props => (
//   <div>Hello {props.name}!</div>
// )

Hello.defaultProps = {
  name: 'David'
}

Hello.propTypes = {
  name: PropTypes.any
}

document.addEventListener('DOMContentLoaded', () => {
  const names = ["a", "b", "c"]
  ReactDOM.render(
    <div>
      <Hello name={names} />
      <FunctionalComponent />
    </div>,
    document.body.appendChild(document.createElement('div')),
  )
})
