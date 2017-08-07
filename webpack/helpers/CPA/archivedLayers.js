export function getArchivedLayers(workId) {
  return this.read(`/archived_works/${workId}/archived_layers`)
             .then(this.checkAJAXResult('layers'))
}

export function updateArchivedLayer(id, attributes) {
  return this.update(`/archived_layers/${id}`, { layer: attributes })
             .then(this.checkAJAXResult('layer'))
}
