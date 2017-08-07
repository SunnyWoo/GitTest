import _ from 'lodash'
import React from 'react'
import { connect } from 'react-redux'
import LayersTableRowStatic from './LayersTableRowStatic'
import LayersTableRowForm from './LayersTableRowForm'
import * as archivedLayersActions from '../modules/archivedLayers'
import { path } from '../helpers/CPA'

function mapStateToProps(state, ownProps) {
  const layer = _.find(state.archivedLayers, { id: ownProps.id })
  return { layer }
}

function mapDispatchToProps(dispatch, ownProps) {
  return {
    updateArchivedLayer(attributes) {
      dispatch(archivedLayersActions.updateArchivedLayer(ownProps.id, attributes))
    }
  }
}

@connect(mapStateToProps, mapDispatchToProps)
export default class LayersTableRow extends React.Component {
  state = { editing: false }

  edit = () => {
    this.setState({ editing: true })
  }

  save = () => {
    this.props.updateArchivedLayer(this.refs.form.getValues())
    this.cancel()
  }

  cancel = () => {
    this.setState({ editing: false })
  }

  enable = () => {
    this.props.updateArchivedLayer({ disabled: false })
  }

  disable = () => {
    this.props.updateArchivedLayer({ disabled: true })
  }

  showVersions = () => {
    Turbolinks.visit(path(`/archived_layers/${this.props.id}/versions`))
  }

  render() {
    if (this.state.editing) {
      return (
        <LayersTableRowForm ref='form' layer={this.props.layer}>
          <button className='btn btn-primary btn-xs' onClick={this.save}>Save</button>
          <button className='btn btn-default btn-xs' onClick={this.cancel}>Cancel</button>
          <button className='btn btn-default btn-xs' onClick={this.showVersions}>Versions</button>
        </LayersTableRowForm>
      )
    } else {
      return (
        <LayersTableRowStatic layer={this.props.layer}>
          <button className='btn btn-default btn-xs' onClick={this.edit}>Edit</button>
          {this.props.layer.disabled ?
            <button className='btn btn-success btn-xs' onClick={this.enable}>Enable</button> :
            <button className='btn btn-danger btn-xs' onClick={this.disable}>Disable</button>}
          <button className='btn btn-default btn-xs' onClick={this.showVersions}>Versions</button>
        </LayersTableRowStatic>
      )
    }
  }
}
