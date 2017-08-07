import _ from 'lodash'
import React from 'react'
import { Input } from 'react-bootstrap'

export default class LayerTypeInput extends React.Component {
  static layerTypes = [
    'camera', 'photo', 'background_color', 'shape', 'crop', 'line', 'sticker',
    'texture', 'typography', 'text', 'lens_flare', 'spot_casting',
    'spot_casting_text', 'varnishing', 'bronzing', 'varnishing_typography',
    'bronzing_typography', 'sticker_asset', 'coating_asset', 'foiling_asset',
    'mask', 'frame'
  ]

  static defaultProps = {
    onChange: _.noop
  }

  constructor(props) {
    super()
    this.state = { value: props.value || 'photo' }
  }

  handleChange = () => {
    const value = this.refs.input.getValue()
    this.setState({ value })
    this.props.onChange({ value })
  }

  getValue() {
    return this.state.value
  }

  render() {
    return (
      <Input type='select' value={this.state.value}
             ref='input' onChange={this.handleChange}>
        {LayerTypeInput.layerTypes.map(type => <option key={type} value={type}>{type}</option>)}
      </Input>
    )
  }
}
