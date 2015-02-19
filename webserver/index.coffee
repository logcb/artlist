FileSystem        = require "fs"
hostname          = "artlist" + (if process.env.NODE_ENV is "production" then ".website" else ".dev")
environment       = process.env.NODE_ENV ? "development"
Artlist           = require "./artlist"
CryptoCredentials = require "./crypto"
SecretPhrase      = FileSystem.readFileSync("secrets/#{hostname}.secret.txt", "utf-8").trim()
MorganLogger      = require "morgan"
Express           = require "express"
HTTPS             = require "https"
Helmet            = require "helmet"
Eco               = require "eco"
Cookie            = require "cookie"

# Exports an instance of [HTTPS server](http://nodejs.org/api/https.html#https_class_https_server)
# with [cryptography credentials](./crypto_credentials.coffee) for this node.
# Routes are defined and dispatched with [Express](http://expressjs.com/4x/api.html).
module.exports = HTTPS.createServer CryptoCredentials, service = new Express

# Log response status, request method, request URL and response time with [Morgan](https://www.npmjs.org/package/morgan#readme).
service.use MorganLogger ":status :method :url :response-time ms"

# Activate strict transport security.
service.use Helmet.hsts maxAge: (24 * 60 * 60 * 1000) * 180

# Set `request.body` from parsed JSON.
service.use require("body-parser").json()

# Serve images, fonts and stylesheets from the filesystem.
service.use "/assets", Express.static("#{__dirname}/../assets")

# Serve compiled bundle script.
service.get "/assets/bundle.js", require("./middleware/bundle_script")

# Serve serialized index data on request.
service.get "/index.json", (request, response, next) ->
  response.writeHead 200, "Content-Type": "application/json; charset=utf-8"
  response.end JSON.stringify(Artlist.index.toJSON(), undefined, 2)

# Serve script to update the `Artlist.index` collection in the window.
service.get "/index.json.js", (request, response, next) ->
  response.writeHead 200, "Content-Type": "application/javascript; charset=utf-8"
  response.end "Artlist.index.set(#{JSON.stringify(Artlist.index.toJSON())});"

# Serve HTML document for any page request.
service.get "/:page?", (request, response, next) ->
  if request.accepts "html"
    if request.header("Cookie")
      permit = Cookie.parse(request.header("Cookie")).permit?
    else
      permit = no
    # console.info cookie = Cookie.parse(request.header("Cookie"))
    response.writeHead 200, "Content-Type": "text/html; charset=utf-8"
    response.end render("document", authorized_to_edit: permit)
  else
    next()

# Post an article to the index.
service.post "/articles", (request, response, next) ->
  model = Artlist.index.add(request.body)
  response.statusCode = 201
  response.json model.toJSON()

# Update an existing exiting article.
service.put "/articles/:id", (request, response, next) ->
  model = Artlist.index.get(request.params.id).set(request.body)
  response.statusCode = 200
  response.json model.toJSON()

# Request a permit to edit the list.
service.put "/permit", (request, response, next) ->
  if request.body.secret_phrase is SecretPhrase
    response.statusCode = 200
    response.setHeader "Set-Cookie", Cookie.serialize("permit", "editor@artlist", {httpOnly:yes, secure:yes})
    response.end()
  else
    response.statusCode = 401
    response.end()

# Expire an existing permit.
service.delete "/permit", (request, response, next) ->
  response.statusCode = 200
  response.setHeader "Set-Cookie", Cookie.serialize("permit", "editor@artlist", {httpOnly:yes, secure:yes, maxAge: 0})
  response.json()

render = (name, params={}) ->
  templatesFolder = __dirname.split("/")[0..-2].join("/") + "/templates"
  template = FileSystem.readFileSync "#{templatesFolder}/#{name}.html", "utf-8"
  params.render = render
  Eco.render template, params
