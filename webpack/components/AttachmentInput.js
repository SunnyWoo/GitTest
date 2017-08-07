import _ from 'lodash'
import React from 'react'
import axios from '../helpers/axiosWithCSRF'
import * as CPA from '../helpers/CPA'
import Dropzone from 'react-dropzone'
import pdf from '../images/pdf.png'
import file from '../images/file.png'
import style from './AttachmentInput.css'

const IMAGE_URL_PATTERN = /\.(jpe?g|gif|png)/
const PDF_URL_PATTERN = /\.pdf/
const IMAGE_MIME_PATTERN = /image/
const PDF_MIME_PATTERN = /pdf/

export default class AttachmentInput extends React.Component {
  static defaultProps = {
    url: CPA.path('/attachments'),
    defaultImage: 'http://placehold.it/200x200',
    onChange: _.noop,
    onError: _.noop
  }

  state = { uploading: false }

  uploadFile = (file) => {
    this.setState({ uploading: true })
    const data = new FormData()
    data.append('file', file)
    axios.post(this.props.url, data).then(this.onUploadDone, this.onUploadFail)
  }

  getPreview = (file) => {
    this.setState({ preview: file.preview, type: file.type })
  }

  previewAndUploadFile = (files) => {
    const file = files[0]
    this.getPreview(file)
    this.uploadFile(file)
  }

  onUploadDone = ({ data }) => {
    this.setState({ uploading: false })
    this.props.onChange(data)
  }

  onUploadFail = (err) => {
    this.props.onError(err)
  }

  render() {
    return (
      <Dropzone onDrop={this.previewAndUploadFile} className={style.uploader}
                activeClassName={style.uploaderActive}>
        <img src={this.renderImage()}></img>
        {this.state.uploading ? this.renderUploading() : null}
      </Dropzone>
    )
  }

  renderImage() {
    return this.renderPreview() || this.renderValue() || this.props.defaultImage
  }

  renderPreview() {
    if (!this.state.preview) {
      return
    }
    switch (false) {
      case !IMAGE_MIME_PATTERN.test(this.state.type): return this.state.preview
      case !PDF_MIME_PATTERN.test(this.state.type):   return pdf
      default:                                        return file
    }
  }

  renderValue() {
    if (!this.props.value) {
      return
    }
    switch (false) {
      case !IMAGE_URL_PATTERN.test(this.props.value): return this.props.value
      case !PDF_URL_PATTERN.test(this.props.value):   return pdf
      default:                                        return file
    }
  }

  renderUploading() {
    return <div className={style.uploading}>Uploading...</div>
  }
}
