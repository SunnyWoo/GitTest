const INCREASE = '@@commandp/counter/increase'
const DECREASE = '@@commandp/counter/decrease'

export default function counter(state = 0, action) {
  switch (action.type) {
    case INCREASE: return state + 1
    case DECREASE: return state - 1
    default:       return state
  }
}

export function increase() {
  return { type: INCREASE }
}

export function decrease() {
  return { type: DECREASE }
}
