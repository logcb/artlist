# This script starts a slowpost [webserver](index.coffee).
# It can be executed on the command line with:
#
# `NODE_PATH=. coffee webserver/start.coffee`
#
# Typically you don’t bother with all that typing and simply do `npm start` or `npm run webserver`.
# {environment, miniLockID} = require "node/environment"
webserver = require "webserver"
environment = "development"
async = require "async"
# Library = require "models/library"
# {permits} = require "node/access"
{writeFile} = require "fs"

# The `port` is where the `webserver` will go to listen for HTTPS requests.
# It may defined in the `process.env` or it may be left `undefined`.
# Default is `443` durring production and `4000` durring development.
port = if environment is "production" then 443 else 4000

# When the `webserver` starts it ensures
# there is a [library](models/library.coffee) for the node operator
# and the operator has a working [access](node/access.coffee) permit.
# If either of these is missing it is created automatically.
#
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
    webserver.listen port, (error) ->
      if error
        console.error(error)
        throw "Can’t listen at port #{port}."
      console.info webserver.address()
      IP = webserver.address().address
      host = "artlist.dev" if environment is "development"
      console.info "Ready at https://#{host or IP}:#{port}/",


# Compile [bundle script](middleware/bundle_script.coffee) and save it in the `webserver/assets/compiled` folder.
compileAndSaveBundleScript = (callback) ->
  async.waterfall [
    (f) -> console.info("Compiling bundle_script..."); f()
    (f) -> require("webserver/middleware/bundle_script").compile f
    (compiled, f) -> writeFile "webserver/assets/compiled/bundle.js", compiled, "utf-8", f
    (f) -> console.info("Wrote webserver/assets/compiled/bundle.js"); f()
  ], callback

# Compile [stylesheet](middleware/stylesheet.coffee). And also save it in the `webserver/assets/compiled` folder.
compileAndSaveStylesheet = (callback) ->
  async.waterfall [
    (f) -> console.info("Compiling stylesheet..."); f()
    (f) -> require("webserver/middleware/stylesheet").compile f
    (compiled, f) -> writeFile "webserver/assets/compiled/stylesheet.css", compiled, "utf-8", f
    (f) -> console.info("Wrote webserver/assets/compiled/stylesheet.css"); f()
  ], callback
