fs = require 'fs'

exports.load = (file_path)->
  body = fs.readFileSync(file_path).toString()
  eval "obj = #{body}"
  return obj
