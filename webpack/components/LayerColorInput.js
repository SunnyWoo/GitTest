import React from 'react'
import { Button } from 'react-bootstrap'
import ColorPicker from 'react-color'

export default class LayerColorInput extends React.Component {
  constructor(props) {
    super()
    this.state = {
      displayColorPicker: false,
      value: props.value || '0x000000'
    }
  }

  toogleColorPicker = () => {
    this.setState({ displayColorPicker: !this.state.displayColorPicker })
  }

  closeColorPicker = () => {
    this.setState({ displayColorPicker: false })
  }

  updateValue = (color) => {
    this.setState({ value: '0x' + color.hex })
  }

  toCSSColor() {
    return this.state.value.replace('0x', '#')
  }

  getValue() {
    return this.state.value
  }

  render() {
    // 設為 relative 是為了讓 ColorPicker 顯示正確
    return (
      <div style={{ position: 'relative' }}>
        <Button active={this.state.displayColorPicker} onClick={this.toogleColorPicker}>{this.state.value}</Button>
        <ColorPicker type='sketch' position='below'
                     color={this.toCSSColor()}
                     display={this.state.displayColorPicker}
                     onChange={this.updateValue}
                     onClose={this.closeColorPicker} />
      </div>
    )
  }
}
