fs = require 'fs'
EventEmitter = require('events').EventEmitter
exports.load = (path) ->
  ee = new EventEmitter()
  if path.charAt(0) != '/' or path.indexOf('..') != -1
    process.nextTick ->
      ee.emit'error', 'Invalid Path'
  else
    fs.stat process.cwd() + path, (err, stats) ->
      if err
        ee.emit 'error', 'File not found.'
      else if stats.size > 1024*1024
        ee.emit'error', 'File larger than the maximum supported size.'
      else
        fs.readFile process.cwd() + path, 'utf8', (err, data) ->
          if err
            ee.emit 'error', 'File could not be read.'
          else
            ee.emit 'success', data
  return ee
