import React from 'react'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import * as counterActions from '../modules/counter'

@connect(
  state => state,
  dispatch => bindActionCreators(counterActions, dispatch)
)
export default class Counter extends React.Component {
  render() {
    return (
      <div>
        <div>{this.props.counter}</div>
        <button onClick={this.props.decrease}>-</button>
        <button onClick={this.props.increase}>+</button>
      </div>
    )
  }
}
