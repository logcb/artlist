HTTP = require "http"

# Exports a HTTP server that redirects visitors to the service with transport layer security.
module.exports = HTTP.createServer (request, response) ->
  response.writeHead 301, "Location": "https://theartlist.ca/"
  response.end()
