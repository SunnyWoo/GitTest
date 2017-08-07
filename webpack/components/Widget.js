import React from 'react'
import classSet from 'classnames'

export default class Widget extends React.Component {
  static defaultProps = {
    icon: 'table'
  }

  render() {
    const { icon, title, toolbar, children } = this.props
    const iconClassNames = classSet('fa ace-icon', 'fa-' + icon)

    return (
      <div className='widget-box widget-color-blue ui-sortable-handle'>
        <div className='widget-header'>
          <h5 className='widget-title bigger lighter'>
            <i className={iconClassNames} />
            {title}
          </h5>
          {toolbar}
        </div>
        <div className='widget-body'>
          <div className='widget-main no-padding'>
            {children}
          </div>
        </div>
      </div>
    )
  }
}
