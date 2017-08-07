import React from 'react'
import { Input } from 'react-bootstrap'

export default class NumberInput extends React.Component {
  constructor(props) {
    super()
    this.state = { value: parseFloat(props.value) || 0 }
  }

  validationState() {
    return isNaN(this.props.value) ? 'error' : 'success'
  }

  handleChange = () => {
    this.setState({ value: parseFloat(this.refs.input.getValue()) })
  }

  getValue() {
    return this.state.value
  }

  render() {
    return (
      <Input type='text' value={this.state.value}
             bsStyle={this.validationState()} ref='input'
             onChange={this.handleChange} />
    )
  }
}
