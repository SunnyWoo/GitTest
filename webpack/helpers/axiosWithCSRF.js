import axios from 'axios'

function getRailsCSRFToken() {
  const metas = document.getElementsByTagName('meta')
  for (let i = 0; i < metas.length; i++) {
    const meta = metas[i]
    if (meta.getAttribute('name') === 'csrf-token') {
      return meta.getAttribute('content')
    }
  }

  return null
}

export default axios.create({
  headers: {
    // 這個 Header 很重要, 如果不加這個的話 Rails 會看不懂 Accept 的內容...
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-Token': getRailsCSRFToken()
  }
})
