import _ from 'lodash'
import * as CPA from '../helpers/CPA'

const LOAD_ARCHIVED_LAYERS = '@@commandp/archivedLayers/LOAD_ARCHIVED_LAYERS'
const UPDATE_ARCHIVED_LAYER = '@@commandp/archivedLayers/UPDATE_ARCHIVED_LAYER'

export default function archivedLayers(state = [], action) {
  switch (action.type) {
    case LOAD_ARCHIVED_LAYERS:  return action.payload
    case UPDATE_ARCHIVED_LAYER:
      return [..._.reject(state, { id: action.payload.id }), action.payload]
    default:                    return state
  }
}

export function loadArchivedLayers(workId) {
  return { type: LOAD_ARCHIVED_LAYERS, payload: CPA.getArchivedLayers(workId) }
}

export function updateArchivedLayer(id, attributes) {
  return { type: UPDATE_ARCHIVED_LAYER, payload: CPA.updateArchivedLayer(id, attributes) }
}
