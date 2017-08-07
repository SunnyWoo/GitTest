import _ from 'lodash'

const PHOTOS = ['camera', 'photo']
const STICKERS = ['shape', 'crop', 'line', 'sticker', 'texture', 'typography',
                  'varnishing_typography', 'bronzing_typography',
                  'sticker_asset', 'coating_asset', 'foiling_asset']
const CUSTOM_SHAPE = ['varnishing', 'bronzing']

const CATEGORY_LAYER_TYPE_MAPPING = {
  // 包含 scale, orientation, position
  geometry: [...PHOTOS, ...STICKERS, 'text', ...CUSTOM_SHAPE, 'mask'],
  color: ['background_color', ...STICKERS, 'text', ...CUSTOM_SHAPE],
  transparent: [...PHOTOS, 'background_color', ...STICKERS, 'text', 'mask'],
  // 包含 fontName, fontText, textSpacing, textAlignment
  text: ['text'],
  // 包含 image, filteredImage, filter
  image: [...PHOTOS, 'text', ...CUSTOM_SHAPE],
  materialName: [...STICKERS, 'mask']
}

const ATTRIBUTE_CATEGORY_MAPPING = {
  scale: 'geometry',
  orientation: 'geometry',
  position: 'geometry',
  positionX: 'geometry',
  positionY: 'geometry',
  fontName: 'text',
  fontText: 'text',
  textSpacing: 'text',
  textAlignment: 'textAlignment',
  filteredImage: 'image',
  filter: 'filter'
}

export function isAvailable(layerType, attribute) {
  const category = ATTRIBUTE_CATEGORY_MAPPING[attribute] || attribute
  return _.includes(CATEGORY_LAYER_TYPE_MAPPING[category], layerType)
}
