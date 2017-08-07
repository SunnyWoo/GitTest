/* global Turbolinks */

// Usage:
//
// In your React app root component:
//
//     import registerReactApp from '../registerReactApp'
//     class App extends React.Component { ... }
//     registerReactApp('App', App)
//
// In HTML:
//
//     <div data-react-app='App' data-react-app-props='<json encoded string>' />
//     // or if you are using erb
//     <%= mount_react_app 'App', props %>
//     // if you need redux store
//     <%= mount_react_app 'App', props, ['reducer1', 'reducer2', ...] %>
import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'react-redux'
import createStore from './createStore'
import * as reducers from '../modules'
import pick from 'lodash/object/pick'

const registeredReactApps = {}

export default function registerReactApp(name, app) {
  if (registeredReactApps[name]) {
    throw 'Error: ' + name + 'has been registered by' + registeredReactApps[name] + '!'
  }
  registeredReactApps[name] = app
}

export function mountReactApps() {
  const nodes = document.querySelectorAll('[data-react-app]')
  for (let i = 0; i < nodes.length; i++) {
    const node = nodes[i]
    mountReactApp(node)
  }
}

export function mountReactApp(node) {
  const App = registeredReactApps[node.dataset['reactApp']]
  const propsJSON = node.dataset['reactAppProps']
  const props = propsJSON && JSON.parse(propsJSON)
  const reducersJSON = node.dataset['reactAppReducers']
  const reducerNames = reducersJSON && JSON.parse(reducersJSON) || []
  if (reducerNames.length > 0) {
    const store = createStore(pick(reducers, reducerNames))
    ReactDOM.render(
      <Provider store={store}>
        <App {...props} />
      </Provider>,
      node
    )
  } else {
    ReactDOM.render(<App {...props} />, node)
  }
}

export function unmountReactApps() {
  const nodes = document.querySelectorAll('[data-react-app]')
  for (let i = 0; i < nodes.length; i++) {
    const node = nodes[i]
    ReactDOM.unmountComponentAtNode(node)
  }
}

export function setup() {
  document.addEventListener(Turbolinks.EVENTS.CHANGE, mountReactApps)
  document.addEventListener(Turbolinks.EVENTS.BEFORE_UNLOAD, unmountReactApps)
}

// Provides a way to mount app from server-side rendered javascript (SRJ)
global.mountReactApp = mountReactApp
