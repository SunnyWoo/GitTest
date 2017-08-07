import 'babel/polyfill'
import './application.scss'
import _ from 'lodash'
import registerReactApp, { setup } from './helpers/registerReactApp'
import { AttachmentInput, Time } from './components'
import { Counter, LayersEditor } from './containers'

_.noConflict()

// 這些只是元件, 不應該被直接使用, 只是為了在 examples 頁面展示才註冊的
registerReactApp('AttachmentInput', AttachmentInput)
registerReactApp('Time', Time)

registerReactApp('Counter', Counter)
registerReactApp('LayersEditor', LayersEditor)
setup()
