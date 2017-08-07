import _ from 'lodash'
import React from 'react'
import { Input } from 'react-bootstrap'
import LayerColorInput from './LayerColorInput'
import LayerImageInput from './LayerImageInput'
import LayerTypeInput from './LayerTypeInput'
import NumberInput from './NumberInput'
import { isAvailable } from '../helpers/layerAttributes'

export default class LayersTableRowForm extends React.Component {
  constructor(props) {
    super()
    this.state = { layerType: props.layer.layerType }
  }

  updateLayerType = (e) => {
    this.setState({ layerType: e.value })
  }

  getValues() {
    return _.inject(
      _.keys(this.refs),
      (values, key) => ({ ...values, [key]: this.refs[key].getValue && this.refs[key].getValue() }),
      {}
    )
  }

  render() {
    const { id, masked } = this.props.layer
    return (
      <tr>
        <td>{!masked && 'Y'}</td>
        <td>{id}</td>
        <td>{this.renderLayerType()}</td>
        <td>{this.renderPosition()}</td>
        <td>{this.renderPositionXY()}</td>
        <td>{this.renderScale()}</td>
        <td>{this.renderOrientation()}</td>
        <td>{this.renderColor()}</td>
        <td>{this.renderTransparent()}</td>
        <td>{this.renderFontName()}</td>
        <td>{this.renderFontText()}</td>
        <td>{this.renderTextSpacing()}</td>
        <td>{this.renderTextAlignment()}</td>
        <td>{this.renderMaterialName()}</td>
        <td>{this.renderImage()}</td>
        <td>{this.renderFilteredImage()}</td>
        <td>{this.renderFilter()}</td>
        <td>{this.props.children}</td>
      </tr>
    )
  }

  isAvailable(attribute) {
    return isAvailable(this.state.layerType, attribute)
  }

  renderOrientation() {
    if (this.isAvailable('orientation')) {
      return <NumberInput ref='orientation' value={this.props.layer.orientation} />
    }
  }

  renderScale() {
    if (this.isAvailable('scale')) {
      return [
        <NumberInput ref='scaleX' key='x' value={this.props.layer.scaleX} />,
        <NumberInput ref='scaleY' key='y' value={this.props.layer.scaleY} />
      ]
    }
  }

  renderColor() {
    if (this.isAvailable('color')) {
      return <LayerColorInput ref='color' value={this.props.layer.color} />
    }
  }

  renderTransparent() {
    if (this.isAvailable('transparent')) {
      return <NumberInput ref='transparent' value={this.props.layer.transparent} />
    }
  }

  renderFontName() {
    if (this.isAvailable('text')) {
      return <Input type='text' ref='fontName' value={this.props.layer.fontName} />
    }
  }

  renderFontText() {
    if (this.isAvailable('text')) {
      return <Input type='text' ref='fontText' value={this.props.layer.fontText} />
    }
  }

  renderImage() {
    if (this.isAvailable('image')) {
      return <LayerImageInput ref='imageAid' value={this.props.layer.image.normal} />
    }
  }

  renderFilteredImage() {
    if (this.isAvailable('image')) {
      return <LayerImageInput ref='filteredImageAid' value={this.props.layer.filteredImage.normal} />
    }
  }

  renderMaterialName() {
    if (this.isAvailable('materialName')) {
      return <Input type='text' ref='materialName' value={this.props.layer.materialName} />
    }
  }

  renderLayerType() {
    return <LayerTypeInput ref='layerType' value={this.props.layer.layerType} onChange={this.updateLayerType} />
  }

  renderPositionXY() {
    if (this.isAvailable('position')) {
      return [
        <NumberInput ref='positionX' key='x' value={this.props.layer.positionX} />,
        <NumberInput ref='positionY' key='y' value={this.props.layer.positionY} />
      ]
    }
  }

  renderTextSpacing() {
    if (this.isAvailable('text')) {
      return [
        <NumberInput ref='textSpacingX' key='x' value={this.props.layer.textSpacingX} />,
        <NumberInput ref='textSpacingY' key='y' value={this.props.layer.textSpacingY} />
      ]
    }
  }

  renderTextAlignment() {
    if (this.isAvailable('text')) {
      return <Input type='text' ref='textAlignment' value={this.props.layer.textAlignment} />
    }
  }

  renderPosition() {
    return <NumberInput ref='position' value={this.props.layer.position} />
  }

  renderFilter() {
    if (this.isAvailable('image')) {
      return <Input type='text' ref='filter' value={this.props.layer.filter} />
    }
  }
}
