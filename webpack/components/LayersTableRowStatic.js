import React from 'react'

export default class LayersTableRowStatic extends React.Component {
  render() {
    const { id, masked, orientation, scaleX, scaleY, color, transparent,
            fontName, fontText, materialName, layerType, positionX, positionY,
            textSpacingX, textSpacingY, textAlignment, position,
            filter } = this.props.layer
    return (
      <tr>
        <td>{!masked && 'Y'}</td>
        <td>{id}</td>
        <td>{layerType}</td>
        <td>{position}</td>
        <td>[{positionX}, {positionY}]</td>
        <td>[{scaleX}, {scaleY}]</td>
        <td>{orientation}</td>
        <td>{color}</td>
        <td>{transparent}</td>
        <td>{fontName}</td>
        <td>{fontText}</td>
        <td>[{textSpacingX}, {textSpacingY}]</td>
        <td>{textAlignment}</td>
        <td>{materialName}</td>
        <td>{this.renderImage()}</td>
        <td>{this.renderFilteredImage()}</td>
        <td>{filter}</td>
        <td>{this.props.children}</td>
      </tr>
    )
  }

  renderImage() {
    return <img src={this.props.layer.image.normal} className='transparent-grid dashed-border' />
  }

  renderFilteredImage() {
    return <img src={this.props.layer.filteredImage.normal} className='transparent-grid dashed-border' />
  }
}
