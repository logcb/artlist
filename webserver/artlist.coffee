Artlist  = module.exports = {}
hostname = if process.env.NODE_ENV is "production" then "theartlist.ca" else "artlist.dev"
Backbone = require "backbone"
Crypto  = require "crypto"
FileSystem = require "fs"
Moment = require "moment"

Artlist.index = new Backbone.Collection JSON.parse(FileSystem.readFileSync("storage/index.json"))

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

Artlist.index.eraseExpiredArticles = ->
  today = Moment().format("YYYY-MM-DD")
  expired = Artlist.index.filter (article) ->
    article.get("date") < today
  console.info "Erasing #{expired.length} expired articles..."
  Artlist.index.remove(expired)
  console.info "Index has #{Artlist.index.length} articles."
  saveIndexOnFileSystem()

Artlist.index.eraseDisposableArticles = ->
  fifteenDaysAgo = Moment().subtract("15", "days").format("YYYY-MM-DD")
  disposable = Artlist.index.filter (article) ->
    article.get("bucket") is "trash" and article.get("trashed_at") < fifteenDaysAgo
  console.info "Erasing #{disposable.length} disposable articles..."
  Artlist.index.remove(disposable)
  console.info "Index has #{Artlist.index.length} articles."
  saveIndexOnFileSystem()

saveIndexOnFileSystem = ->
  FileSystem.writeFileSync "storage/index.json", JSON.stringify(Artlist.index.toJSON(), undefined, "  "), "utf-8"

SecretPhrase = FileSystem.readFileSync("secrets/#{hostname}.secret.txt", "utf-8").trim()

Artlist.permits = new Backbone.Collection JSON.parse(FileSystem.readFileSync("storage/permits.json"))

Artlist.permits.generateIdentifer = ->
  hash = Crypto.createHash("sha1")
  hash.update(Crypto.randomBytes(256))
  hash.digest("hex")

Artlist.permits.authorize = (secretPhraseInput) ->
  if secretPhraseInput is SecretPhrase
    @add id: @generateIdentifer()
  else
    undefined

Artlist.permits.on "add remove", (model) ->
  savePermitsOnFileSystem()

savePermitsOnFileSystem = ->
  FileSystem.writeFileSync "storage/permits.json", JSON.stringify(Artlist.permits.toJSON(), undefined, "  "), "utf-8"
