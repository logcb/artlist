Artlist  = module.exports = {}
Backbone = require "backbone"
crypto  = require "crypto"
{readFileSync, writeFileSync} = require "fs"

Artlist.index = new Backbone.Collection JSON.parse(readFileSync("storage/index.json"))

Artlist.index.comparator = (model) -> model.get("date") + model.get("time")

Artlist.index.on "add", (model) ->
  model.set {"created_at": (new Date).toJSON()}, silent: yes
  model.set {"updated_at": (new Date).toJSON()}, silent: yes
  Artlist.index.sort()
  saveIndexOnFileSystem()

Artlist.index.on "change:destination_bucket", (model) ->
  return if model.isNew()
  model.unset "pending_at", silent: yes
  model.unset "published_at", silent: yes
  model.unset "trashed_at", silent: yes
  switch model.get("destination_bucket")
    when "pending"
      model.set "bucket", "pending", silent: yes
    when "published"
      model.set "bucket", "published", silent: yes
      model.set "published_at", (new Date).toJSON(), silent: yes
    when "trash"
      model.set "bucket", "trash", silent: yes
      model.set "trashed_at", (new Date).toJSON(), silent: yes
  model.unset "destination_bucket", silent: yes
  console.info "Model #{model.id} moved to #{model.get("bucket")}"

Artlist.index.on "change", (model) ->
  return if model.isNew()
  model.set {"updated_at": (new Date).toJSON()}, silent: yes
  Artlist.index.sort()
  saveIndexOnFileSystem()

saveIndexOnFileSystem = ->
  writeFileSync "storage/index.json", JSON.stringify(Artlist.index.toJSON(), undefined, "  "), "utf-8"
