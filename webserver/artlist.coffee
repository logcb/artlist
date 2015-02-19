Artlist  = module.exports = {}
Backbone = require "backbone"
crypto  = require "crypto"
{readFileSync, writeFileSync} = require "fs"

Artlist.index = new Backbone.Collection JSON.parse(readFileSync("storage/index.json"))

Artlist.index.comparator = (model) -> model.get("date") + model.get("time")

Artlist.index.on "add", (model) ->
  model.set "created_at": (new Date).toJSON()
  model.set "updated_at": (new Date).toJSON()
  model.set "id", generateIdentifierForNewArticle(model.toJSON())
  Artlist.index.sort()
  saveIndexOnFileSystem()

Artlist.index.on "change", (model) ->
  return if model.isNew()
  model.set "updated_at": (new Date).toJSON()
  Artlist.index.sort()
  saveIndexOnFileSystem()

generateIdentifierForNewArticle = (attributes) ->
  hash = crypto.createHash("sha1")
  hash.update(JSON.stringify(attributes), "utf-8")
  hash.digest("hex")

saveIndexOnFileSystem = ->
  writeFileSync "storage/index.json", JSON.stringify(Artlist.index.toJSON(), undefined, "  "), "utf-8"
