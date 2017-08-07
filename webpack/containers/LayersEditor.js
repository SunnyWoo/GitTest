import React from 'react'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { LayersTable, Widget } from '../components'
import * as archivedLayersActions from '../modules/archivedLayers'

@connect(
  state => state,
  dispatch => bindActionCreators(archivedLayersActions, dispatch)
)
export default class LayersEditor extends React.Component {
  componentDidMount() {
    this.props.loadArchivedLayers(this.props.workId)
  }

  render() {
    return <Widget title='Layers'>{this.renderLayers()}</Widget>
  }

  renderLayers() {
    if (this.props.archivedLayers) {
      return <LayersTable layers={this.props.archivedLayers} />
    } else {
      return <div>Loading...</div>
    }
  }
}
