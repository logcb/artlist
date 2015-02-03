# This script starts THE ARTLIST webserver. Execute it on the command line with:
#
#    NODE_ENV=production coffee webserver/start.coffee
#
# Typically you don’t bother with all that typing and simply do `npm start`.

webserver   = require "./index"
environment = process.env.NODE_ENV ? "development"
async       = require "async"
{writeFile} = require "fs"

# The `port` is where the `webserver` will go to listen for HTTPS requests.
# It is set to `443` durring production and `4000` durring development.
port = if environment is "production" then 443 else 4000

# The [bundle script](middleware/bundle_script.coffee) and
# [stylesheet](middleware/stylesheet.coffee)
# are pre-compiled and saved to `webserver/assets/compiled`
# when the process is running in production.
# Pre-compiling these assets reduces their response latency in the [window](../window/index.coffee)
# and it reduces the load on the `webserver`.
#
# When the startup tasks are complete
# the `webserver` is connected to the `port`
# where it will listen for requests from existing node members
# and members-to-be-or-not-to-be.
process.nextTick ->
  startupTasks = []
  startupTasks.push compileAndSaveBundleScript if environment is "production"
  startupTasks.push compileAndSaveStylesheet if environment is "production"
  async.series startupTasks, (error) ->
    if error
      console.error(error)
      throw "Can’t start webserver because a startup task has failed."
    else
      bindToPortAndBeginListening()

bindToPortAndBeginListening = ->
  webserver.listen port, (error) ->
    if error
      console.error(error)
      throw "Can’t listen at port #{port}."
    console.info webserver.address()
    IP = webserver.address().address
    host = "artlist.dev" if environment is "development"
    console.info "Ready at https://#{host or IP}:#{port}/",

# Compile [bundle script](middleware/bundle_script.coffee) and save it in the `assets/compiled` folder.
compileAndSaveBundleScript = (callback) ->
  async.waterfall [
    (f) -> console.info("Compiling bundle.js..."); f()
    (f) -> require("webserver/middleware/bundle_script").compile f
    (compiled, f) -> writeFile "assets/compiled/bundle.js", compiled, "utf-8", f
    (f) -> console.info("Wrote assets/compiled/bundle.js"); f()
  ], callback
