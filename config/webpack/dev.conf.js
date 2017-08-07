// Example webpack configuration with asset fingerprinting in production.
'use strict';

var path = require('path');
var webpack = require('webpack');
var StatsPlugin = require('stats-webpack-plugin');

// must match config.webpack.dev_server.port
var devServerPort = 3808;

// set TARGET=production on the environment to add asset fingerprints
var production = false;

var config = {
  entry: {
    // Sources are expected to live in $app_root/webpack
    'application': [
      'webpack-dev-server/client?http://localhost:' + devServerPort + '/',
      'webpack/hot/only-dev-server',
      './webpack/application.js'
    ]
  },

  devServer: {
    port: devServerPort,
    headers: { 'Access-Control-Allow-Origin': '*' }
  },

  output: {
    // Build assets directly in to public/webpack/, let webpack know
    // that all webpacked assets start with webpack/

    // must match config.webpack.output_dir
    path: path.join(__dirname, '..', '..', 'public', 'webpack'),
    publicPath: '//localhost:' + devServerPort + '/webpack/',

    filename: production ? '[name]-[chunkhash].js' : '[name].js'
  },

  devtool: 'cheap-module-eval-source-map',

  resolve: {
    root: path.join(__dirname, '..', '..', 'webpack'),
    extensions: ['', '.js']
  },

  module: {
    loaders: [
      { test: /\.js$/, exclude: /node_modules/, loaders: ['react-hot', 'babel'] },
      { test: /\.css$/, loader: 'style!css!autoprefixer?browsers=last 2 version' },
      { test: /\.scss$/, loader: 'style!css!autoprefixer?browsers=last 2 version!sass' },
      { test: /\.(jpe?g|png|gif)$/, loader: 'url-loader?limit=10240' }
    ]
  },

  plugins: [
    // must match config.webpack.manifest_filename
    new StatsPlugin('manifest.json', {
      // We only need assetsByChunkName
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true
    })
  ]
};

module.exports = config;
