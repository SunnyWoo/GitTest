# @cjsx
@CPA.HomeBlocks.TranslationsImageInput = React.createClass

  propTypes:
    blockItemId:     React.PropTypes.number.isRequired
    picTranslations: React.PropTypes.object.isRequired
    onChange:        React.PropTypes.func

  render: ->
    <div className='center-cropped-container'>
      { _.map @props.picTranslations, (value, locale) =>
          formData =
            blockItemId: @props.blockItemId
            localeAttr:  locale
          <div className='home-block-item-image'>
            <CPA.Base.ImageInput name='pic'
                                 url={CPA.path("/home_block_item_translations/update_pic")}
                                 value={value}
                                 type='PATCH'
                                 onChange={@props.onChange}
                                 formData={humps.decamelizeKeys(formData)} />
            <div className='home-block-item-image-text'>{locale}</div>
          </div>
      }
    </div>

