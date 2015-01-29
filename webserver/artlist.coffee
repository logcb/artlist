Artlist  = module.exports = {}
Backbone = require "backbone"
BLAKE2s  = require "blake2s-js"
{readFileSync, writeFileSync} = require "fs"

Artlist.index = new Backbone.Collection JSON.parse(readFileSync("index.json"))
Artlist.index.comparator = "created_at"

Artlist.index.on "add", (model) ->
  model.set "created_at": (new Date).toJSON()
  model.set "updated_at": (new Date).toJSON()
  model.set "id", generateIdentifierForNewArticle(model.toJSON())
  Artlist.index.sort()
  saveIndexOnFileSystem()

generateIdentifierForNewArticle = (attributes) ->
  hash = new BLAKE2s 32
  hash.update(Date.now())
  hash.update(attributes)
  hash.hexDigest()

saveIndexOnFileSystem = ->
  writeFileSync "index.json", JSON.stringify(Artlist.index.toJSON()), "utf-8"
