environment = process.env.NODE_ENV ? "development"
Browserify = require "browserify"
CoffeeScript = require "coffee-script"
Eco = require "eco"
FileSystem = require "fs"
Zepto = FileSystem.readFileSync "assets/zepto.js", "utf-8"
through = require "through"

module.exports = (request, response, next) ->
  compile (error, bundle) ->
    if bundle
      response.writeHead 200, "Content-Type": "application/javascript; charset=utf-8"
      response.end bundle
    else
      next(error)

compile = (callback) ->
  if compile.cache and environment isnt "development"
    callback undefined, compile.cache
  else
    # Define the file extensions that can be required in the bundle.
    browserify = Browserify extensions: [".coffee", ".html"]
    # Don’t need jqeury in the bundle.
    browserify.exclude("jquery")
    # Define transformations for CoffeeScript code and Eco templates.
    browserify.transform convertSourceFileToJavascript
    # Require all the templates.
    browserify.require("./templates/#{file}") for file in FileSystem.readdirSync("templates") when file.match(".html")
    # Require the bundle index file.
    browserify.add("./window/index")
    # Bundle the script and send a buffer to the `callback`.
    browserify.bundle (error, buffer) ->
      if error
        callback error
      else
        compile.cache = Zepto + "\n" + buffer.toString()
        callback undefined, compile.cache

convertSourceFileToJavascript = (file) ->
    data = ''
    write = (buffer) -> data += buffer
    end = switch
      when file.match(".coffee")
        ->
          javascript = CoffeeScript.compile(data)
          @queue(javascript)
          @queue(null)
      when file.match(".html")
        ->
          javascript = "(function(){ module.exports = #{Eco.precompile(data)}; }).call(this);"
          @queue(javascript)
          @queue(null)
    through(write, end)
