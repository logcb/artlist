{readFileSync, writeFileSync} = require "fs"

environment       = "development"
hostname          = "artlist.dev"
Artlist           = require "./artlist"
CryptoCredentials = require "./crypto_credentials"
MorganLogger      = require "morgan"
Express           = require "express"
ExpressSession    = require "express-session"
HTTPS             = require "https"
Eco               = require "eco"

# Exports an instance of [HTTPS server](http://nodejs.org/api/https.html#https_class_https_server)
# with [cryptography credentials](./crypto_credentials.coffee) for this node.
# Routes are defined and dispatched with [Express](http://expressjs.com/4x/api.html).
module.exports = HTTPS.createServer CryptoCredentials, service = new Express

# Log response status, request method, request URL and response time with [Morgan](https://www.npmjs.org/package/morgan#readme).
service.use MorganLogger ":status :method :url :response-time ms"

# Activate strict transport security and define the content security policy with
# [Helmet](https://www.npmjs.org/package/helmet#readme).
# Helmet = require "helmet"
#
# service.use Helmet.hsts maxAge: (24.hours()) * 180
# service.use Helmet.csp
#   defaultSrc: "'self' data:"
#   scriptSrc: "'self'"
#   styleSrc: "'self' 'unsafe-inline'"
# service.use Helmet.hidePoweredBy()
# service.use Helmet.xframe()
# service.use Helmet.xssFilter()

# Serve images and compiled scripts and stylesheets from the filesystem.
service.use "/assets", Express.static("#{__dirname}/../assets")
service.use Express.static("#{__dirname}/..")

# Compile [bundle script](middleware/bundle_script.coffee), [stylesheet](middleware/stylesheet.coffee) on demand durring development.
service.get "/assets/bundle.js", require("./middleware/bundle_script")
service.get "/assets/compiled/stylesheet.css", require("./middleware/stylesheet")



service.get "/index.json.js", (request, response, next) ->
  response.writeHead 200, "Content-Type": "application/javascript; charset=utf-8"
  response.end "Artlist.index.set(#{JSON.stringify(Artlist.index.toJSON())});"

# Set `request.body` from parsed JSON.
service.use require("body-parser").json()

# Define cookie parameters for `request.session`.
service.use ExpressSession
  name: "artlist_session"
  secret: process.env["artlist_session_secret"] or "Not a very good secret but it will do for now."
  cookie: {secure: yes, httpOnly: no}
  resave: no
  saveUninitialized: no

service.post "/articles", (request, response, next) ->
  model = Artlist.index.add(request.body)
  response.statusCode = 201
  response.json model.toJSON()

service.put "/articles/:id", (request, response, next) ->
  model = Artlist.index.get(request.params.id).set(request.body)
  response.statusCode = 200
  response.json model.toJSON()

service.get "/:page", (request, response, next) ->
  if request.accepts "html"
    page = request.params.page || "index"
    HTML = render(page, {})
    response.writeHead 200, "Content-Type": "text/html; charset=utf-8"
    response.end HTML
  else
    next()

render = (name, params={}) ->
  templatesFolder = __dirname.split("/")[0..-2].join("/") + "/templates"
  template = readFileSync "#{templatesFolder}/#{name}.html", "utf-8"
  params.render = render
  Eco.render template, params
