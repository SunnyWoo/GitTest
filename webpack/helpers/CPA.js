// CPA stands for CommandP Admin
export function path(path) {
  if (location.pathname.match(/.+\/admin/)) {
    return location.pathname.match(/.+\/admin/)[0] + path
  } else {
    return path
  }
}

export * from './CPA/ajax'
export * from './CPA/archivedLayers'
