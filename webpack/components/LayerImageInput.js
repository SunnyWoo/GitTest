import React from 'react'
import AttachmentInput from './AttachmentInput'

export default class LayerImageInput extends React.Component {
  constructor() {
    super()
    this.state = { value: null }
  }

  updateValue = (value) => {
    this.setState({ value: value.attachment.id })
  }

  getValue() {
    return this.state.value
  }

  render() {
    return (
      <AttachmentInput ref='image' value={this.props.value}
                       onChange={this.updateValue} />
    )
  }
}
