import _ from 'lodash'
import React from 'react'
import { LayersTableRow } from '../components'

export default class LayersTable extends React.Component {
  sortedLayers() {
    return _.reduce(
      this.rootLayers(),
      (layers, layer) => layers.concat([layer]).concat(this.maskedLayers(layer)),
      []
    )
  }

  rootLayers() {
    return _.sortBy(_.where(this.props.layers, { masked: false }), 'position')
  }

  maskedLayers(layer) {
    const layerIds = _.pluck(layer.maskedLayers, 'id')
    return _.sortBy(_.filter(this.props.layers, layer => _.includes(layerIds, layer.id)), 'position')
  }

  render() {
    return (
      <table className='table table-striped table-bordered table-hover table-condensed'>
        <thead>
          <tr>
            <th>mask</th>
            <th>id</th>
            <th>layer_type</th>
            <th>position</th>
            <th>position</th>
            <th>scale</th>
            <th>orientation</th>
            <th>color</th>
            <th>transparent</th>
            <th>font_name</th>
            <th>font_text</th>
            <th>text_spacing</th>
            <th>text_alignment</th>
            <th>material_name</th>
            <th>image</th>
            <th>filtered_image</th>
            <th>filter</th>
            <th>operations</th>
          </tr>
        </thead>
        <tbody>
          {this.sortedLayers().map(layer => <LayersTableRow key={layer.id} id={layer.id} />)}
        </tbody>
      </table>
    )
  }
}
