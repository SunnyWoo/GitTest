// Example webpack configuration with asset fingerprinting in production.
'use strict';

var path = require('path');
var webpack = require('webpack');
var StatsPlugin = require('stats-webpack-plugin');

// must match config.webpack.dev_server.port
var devServerPort = 3808;

var config;
if (process.env.TARGET === 'production' || process.env.TARGET === 'staging' || process.env.TARGET === 'sandbox' || process.env.TARGET === 'production_ready') {
  config = require('./webpack/prod.conf.js')
} else {
  config = require('./webpack/dev.conf.js')
}

module.exports = config;
