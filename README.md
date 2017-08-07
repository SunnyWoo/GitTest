[ ![Codeship Status for commandp/commandp-service](https://codeship.com/projects/8cf69e20-b0fe-0131-b4fc-7a7574aafb15/status?branch=develop)](https://codeship.com/projects/19892)
[![Code Climate](https://codeclimate.com/repos/5719a183474391006f002b70/badges/d916e9564f97dbd8b295/gpa.svg)](https://codeclimate.com/repos/5719a183474391006f002b70/feed)
[![Test Coverage](https://codeclimate.com/repos/5719a183474391006f002b70/badges/d916e9564f97dbd8b295/coverage.svg)](https://codeclimate.com/repos/5719a183474391006f002b70/coverage)
[![Issue Count](https://codeclimate.com/repos/5719a183474391006f002b70/badges/d916e9564f97dbd8b295/issue_count.svg)](https://codeclimate.com/repos/5719a183474391006f002b70/feed)

# 系統需求

- PostgreSQL >= 9.3
- Elasticsearch >= 1.7
- InfluxDB >= 0.9
- Redis >= 3.0
- Ruby >= 2.0
- Node.js >= 5.3

# 如何開始

- 安裝 Elasticsearch `brew install homebrew/versions/elasticsearch17` 並啟動之. 如果已安裝其他版本請先移除
  `brew uninstall --force elasticsearch`
- 複製 `config/application.yml.ci`, `config/database.yml.ci`, `paypal.yml.ci` 成沒有 .ci 結尾的檔名
- 修改 `config/database.yml` 成你習慣的樣子
- `npm install`
- `bundle install`
- `pre-commit install`
- `rake db:create db:migrate db:test:clone db:seed_fu`
- `echo 3000 > ~/.pow/commandp`
- 使用 `foreman start` 啟動 sidekiq, rails server 與 webpack dev server
- 這樣應該就可以上 http://commandp.dev 了

# [ApiDocs] Api 文件

目前 ApiV2 與 ApiV3 的的 API 文件是採用 [apidocs](http://apidocjs.com/) 的格式,
舊文件請至 {WIKI} 頁查詢。

## Install apidocs

### 需要 nodejs

``` bash
brew install nvm
nvm install
```

### 執行 npm install

`npm install apidoc -g`

## Generate apidocs

於 repo 下執行 `./bin/commandp_docs` 將會產生文檔於 `doc/` 下

## 開啟文件

- ApiV2: `open doc/apiv2doc/index.html`
- ApiV3: `open doc/apiv3doc/index.html`


# ElasticSearch 安裝與設定

## (Mac)安裝

```
brew install elasticsearch
ln -sfv /usr/local/opt/elasticsearch/*.plist ~/Library/LaunchAgents
(start) launchctl load ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch.plist
(stop) launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch.plist
```

### Install Plugin

```
plugin -install mobz/elasticsearch-head  #Elasticsearch Web 瀏覽介面
```

在開啟瀏覽器 http://localhost:9200/_plugin/head/



## Model init

目前有使用到的 Model：`User`, `Work`

### 建立 ElasticSearch Index

```
Work.initialize_elasticsearch
User.initialize_elasticsearch
```

### 重置 ElasticSearch Index

```
Work.re_initialize_elasticsearch
```

### Import 資料到 ElasticSearch

```
Work.import_elasticsearch 自訂的 Import
User.import  Import 全部的資料
```

# Install Influxdb (Mac)

```sh
brew install influxdb
ln -sfv /usr/local/opt/influxdb/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.influxdb.plist
```

### influxdb 設定

基本上 host 沒資料的話，就不會丟東西給 influxdb

```yaml
# vi application.yml
  InfluxDB:
    host: '127.0.0.1'
    port: 8086
    db_name: 'mydb'
    username: 'root'
    password: 'root'
```

### 新增 influxdb database

```sh
$ influx -execute 'CREATE DATABASE mydb;'
```
