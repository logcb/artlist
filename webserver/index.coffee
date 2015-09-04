FileSystem        = require "fs"
hostname          = if process.env.NODE_ENV is "production" then "theartlist.ca" else "artlist.dev"
environment       = process.env.NODE_ENV ? "development"
Artlist           = require "./artlist"
MorganLogger      = require "morgan"
Express           = require "express"
HTTPS             = require "https"
Helmet            = require "helmet"
Eco               = require "eco"
Cookie            = require "cookie"
Crypto            = require "crypto"
Moment            = require "moment"


# Read SSL certificate and secret key from the file system.
CryptoCredentials =
  cert: FileSystem.readFileSync "webserver/crypto/#{hostname}.certificates.pem"
  key:  FileSystem.readFileSync "secrets/#{hostname}.secret.key"

# Exports an instance of [HTTPS server](http://nodejs.org/api/https.html#https_class_https_server)
# with [cryptography credentials](./crypto_credentials.coffee) for this node.
# Routes are defined and dispatched with [Express](http://expressjs.com/4x/api.html).
module.exports = HTTPS.createServer CryptoCredentials, service = new Express

# Log response status, request method, request URL and response time with [Morgan](https://www.npmjs.org/package/morgan#readme).
service.use MorganLogger ":status :method :url :response-time ms"

# Activate strict transport security.
service.use Helmet.hsts maxAge: (24 * 60 * 60 * 1000) * 180

# Define the content security policy.
service.use Helmet.csp
  'default-src': "'none'"
  'connect-src': "'self'"
  'font-src':    "'self'"
  'img-src':     "'self'"
  'script-src':  "'self'"
  'style-src':   "'self' 'unsafe-inline'"

# Set `request.body` from parsed JSON.
service.use require("body-parser").json()

# Serve images, fonts and stylesheets from the filesystem.
service.use "/assets", Express.static("#{__dirname}/../assets")

# Define `request.permit` when the cookie contains a valid permit identifier.
service.use (request, response, next) ->
  request.permit = if request.header("Cookie")?
    Artlist.permits.get(Cookie.parse(request.header("Cookie")).permit)
  else
    undefined
  next()

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
    response.writeHead 200, "Content-Type": "text/html; charset=utf-8"
    response.end render("document", {permit: request.permit})
  else
    next()

# Post an article to the index.
service.post "/articles", (request, response, next) ->
  attributes = {id: generateIdentifierForNewArticle(request.body)}
  attributes[name] = request.body[name] for name in ["title", "venue", "cost", "date", "time", "description", "category", "web_address"]
  model = Artlist.index.add(attributes)
  response.statusCode = 201
  response.json model.toJSON()

# Update an existing exiting article.
service.put "/articles/:id", (request, response, next) ->
  if request.permit
    attributes = {}
    attributes[name] = request.body[name] for name in ["title", "venue", "cost", "date", "time", "description", "category", "web_address", "destination_bucket"]
    model = Artlist.index.get(request.params.id).set(attributes)
    response.statusCode = 200
    response.json model.toJSON()
  else
    response.statusCode = 401
    response.end()

# Request a permit to edit the list.
service.put "/permit", (request, response, next) ->
  if permit = Artlist.permits.authorize(request.body.secret_phrase)
    response.statusCode = 200
    response.setHeader "Set-Cookie", Cookie.serialize("permit", permit.id, {httpOnly:yes, secure:yes})
    response.end()
  else
    response.statusCode = 401
    response.end()

# Expire an existing permit.
service.delete "/permit", (request, response, next) ->
  if permit = request.permit
    Artlist.permits.remove(permit)
    response.statusCode = 200
    response.setHeader "Set-Cookie", Cookie.serialize("permit", permit.id, {httpOnly:yes, secure:yes, maxAge: 0})
    response.end()
  else
    response.statusCode = 401
    response.end()

render = (name, params={}) ->
  templatesFolder = __dirname.split("/")[0..-2].join("/") + "/templates"
  template = FileSystem.readFileSync "#{templatesFolder}/#{name}.html", "utf-8"
  params.render = render
  Eco.render template, params

generateIdentifierForNewArticle = (requestBody) ->
  hash = Crypto.createHash("sha1")
  hash.update(JSON.stringify(requestBody), "utf-8")
  "ART" + hash.digest("hex")

# Erase expired articles at startup and periodically thereafter.
process.nextTick Artlist.index.eraseExpiredArticles
setInterval Artlist.index.eraseExpiredArticles, Moment.duration(1, "hour")

# Erase disposable articles at startup and periodically thereafter.
process.nextTick Artlist.index.eraseDisposableArticles
setInterval Artlist.index.eraseDisposableArticles, Moment.duration(1, "hour")
