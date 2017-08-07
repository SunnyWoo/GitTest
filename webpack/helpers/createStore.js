import { createStore as createReduxStore,
         combineReducers,
         applyMiddleware,
         compose } from 'redux'
import promiseMiddleware from 'redux-promise'

export default function createStore(reducers) {
  const reducer = combineReducers(reducers)

  let enhancers = [
    applyMiddleware(
      promiseMiddleware
    ),
    global.devToolsExtension ? global.devToolsExtension() : f => f
  ]

  const store = compose(...enhancers)(createReduxStore)(reducer)
  return store
}
