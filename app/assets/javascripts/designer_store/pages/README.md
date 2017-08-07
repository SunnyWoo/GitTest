## Modules
本資料夾放專案「特定頁面」所需的程式碼，如 `works_edit_page.coffee`, `works_share_page.coffee`

## 檔案
檔案最上方需加上:

```js
$(document).on 'page:change', ->
  return if $('body.here_is_controller_name.here_is_action_name').length == 0

  // ... your code here ... ///
```

讓每次換頁的時候判斷是不是特定頁面，如果不是，就不執行以下的程式碼
