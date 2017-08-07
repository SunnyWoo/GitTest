import humps from 'humps'
import axios from '../axiosWithCSRF'
// ES6 不給 export function delete, 因為 delete 是關鍵字...
// 所以乾脆改用 CRUD 風格命名了

// performs GET /zh-TW/admin/{path} and returns a promise
export function read(path, config) {
  return axios.get(this.path(path), config)
}

// performs POST /zh-TW/admin/{path} and returns a promise
export function create(path, data, config) {
  return axios.post(this.path(path), humps.decamelizeKeys(data), config)
}

// performs PATCH /zh-TW/admin/{path} and returns a promise
export function update(path, data, config) {
  return axios.patch(this.path(path), humps.decamelizeKeys(data), config)
}

// performs DELETE /zh-TW/admin/{path} and returns a promise
export function destroy(path, config) {
  return axios.delete(this.path(path), config)
}

// checks the result that contains given key or not
export function checkAJAXResult(key) {
  return response => {
    if (response.data[key]) {
      return humps.camelizeKeys(response.data[key])
    }
    throw `Couldn't find ${key} in ${response.config.method.toUpperCase()} ${response.config.url}`
  }
}
