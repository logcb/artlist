environment = "development"

stylus = require "stylus"
{readdir}  = require "fs"
{basename} = require "path"

module.exports = (request, response, next) ->
  compile (error, css) ->
    if css
      response.writeHead 200, "Content-Type": "text/css"
      response.end css
    else
      next(error)

compile = module.exports.compile = (callback) ->
  if compile.cache and environment isnt "development"
    callback(undefined, compile.cache)
  else
    readdir "window/stylesheets", (error, paths) ->
      sheets = (path for path in paths when /\.styl$/.test(path))
      source = ("@import #{basename(sheet, '.styl')}" for sheet in sheets).join("\n")
      s = stylus source, paths: ["window/stylesheets"]
      s.define "url", stylus.url(paths:[__dirname + "/../assets/images"])
      s.render (error, css) ->
        if css
          compile.cache = css
        callback(error, css)
