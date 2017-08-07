import React from 'react'
import classSet from 'classnames'
import style from './Time.css'

export default class Time extends React.Component {
  constructor() {
    super()
    this.state = { time: new Date() }
  }

  componentDidMount() {
    this.timer = setInterval(this.updateTime, 1000)
  }

  componentWillUnmount() {
    clearInterval(this.timer)
  }

  updateTime = () => {
    this.setState({ time: new Date() })
  }

  render() {
    return <div className={classSet(style.time)} {...this.props}>{this.state.time.toString()}</div>
  }
}
