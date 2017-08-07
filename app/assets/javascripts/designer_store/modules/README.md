## Modules
本資料夾放專案所需的 `JavaScript` 元件，如 `kv.coffee`, `lightbox.coffee`, `editor.coffee`

## 檔案
檔案最上方需加上如下程式碼：

```js
$(document).on 'page:change', ->
  // ...your code here
```

讓每次換頁的時候，本檔案的程式碼會重新被執行
