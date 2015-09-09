# This script starts THE ARTLIST webservers. Execute it on the command line with:
#
#    NODE_ENV=production coffee webserver/start.coffee
#
# Typically you don’t bother with all that typing and simply do `npm start`.

environment = process.env.NODE_ENV ? "development"

process.nextTick ->
  startWebserver()
  startUsher()

startWebserver = ->
  webserver = require "./index"
  port = if environment is "production" then 443 else 4000
  webserver.listen port, "0.0.0.0", (error) ->
    if error
      console.error(error)
      throw "Can’t listen at port #{port}."
    else
      console.info "Webserver address is", webserver.address()

startUsher = ->
  usher = require "./usher"
  port = if environment is "production" then 80 else 8080
  usher.listen port, "0.0.0.0", (error) ->
    if error
      console.error(error)
      throw "Can’t listen at port #{port}."
    else
      console.info "Usher address is", usher.address()
