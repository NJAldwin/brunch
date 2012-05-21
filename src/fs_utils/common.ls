fs = require 'fs'
{EventEmitter} = require 'events'
mkdirp = require 'mkdirp'
{ncp} = require 'ncp'
sysPath = require 'path'
logger = require '../logger'

exports.exists = fs.exists or sysPath.exists

# Creates file if it doesn't exist and writes data to it.
# Would also create a parent directories if they don't exist.
#
# path - path to file that would be written.
# data - data to be written
# callback(error, path, data) - would be executed on error or on
#    successful write.
# 
# Example
# 
#   writeFile 'test.txt', 'data', (error) -> console.log error if error?
# 
exports.writeFile = (path, data, callback) ->
  logger.debug "Writing file '#{path}'"
  write = (callback) -> fs.writeFile path, data, callback
  error <- write
  return callback null, path, data unless error?
  error <- mkdirp (sysPath.dirname path), 0o755
  return callback error if error?
  error <- write
  callback error, path, data

# RegExp that would filter invalid files (dotfiles, emacs caches etc).
ignoredRe = /(^(\.|#)|__$)/;

exports.ignored = ignored = (path) ->
  ignoredRe.test(sysPath.basename path)

exports.copyIfExists = (source, destination, filter = yes, callback) ->
  options = if filter then {filter: ((path) -> not ignored path)} else {}
  exists <- sysPath.exists source
  return callback! unless exists
  ncp source, destination, options, callback
