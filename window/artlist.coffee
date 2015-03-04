{extend} = require "underscore"
Backbone = require "backbone"
Moment = require "moment"

module.exports = Artlist = {}

# Each event on THE ARTLIST is represented by an instance of the Article class.

class Artlist.Article extends Backbone.Model
  urlRoot: "/articles"

  defaults: ->
    date: Moment(Date.now()).format("YYYY-MM-DD")
    time: "16:30"
    category: "Community"
    cost: "Free"
    bucket: "pending"

  moveToPendingBucket: (options) ->
    @save {"destination_bucket": "pending"}, options

  moveToPublishedBucket: (options) ->
    @save {"destination_bucket": "published"}, options

  moveToTrashBucket: (options) ->
    @save {"destination_bucket": "trash"}, options

  isPending: ->
    @get("bucket") is "pending"

  isMovingToPendingBucket: ->
    @get("destination_bucket") is "pending"

  isPublished: ->
    @get("bucket") is "published"

  isMovingToPublishedBucket: ->
    @get("destination_bucket") is "published"

  isTrash: ->
    (@get("bucket") is "trash") and @get("trashed_at")

  isMovingToTrashBucket: ->
    (@get("bucket") is "trash") and (@get("trashed_at") is undefined)

  isNotTrash: ->
    @isTrash() is no

  validate: (attributes, options) ->
    if attributes.title is undefined
      return ["title", "can’t be blank"]
    if attributes.venue is undefined
      return ["venue", "can’t be blank"]
    if attributes.date is undefined
      return ["date", "can’t be blank"]
    if attributes.time is undefined
      return ["time", "can’t be blank"]
    if attributes.description is undefined
      return ["description", "can’t be blank"]
    if attributes.web_address is undefined
      return ["web_address", "can’t be blank"]

# Article collections.

class Artlist.Article.Collection extends Backbone.Collection
  model: Artlist.Article

  filterByDate: (date) ->
    @filter (article) -> article.get("date") is date

Artlist.index     = new Artlist.Article.Collection
Artlist.pending   = new Artlist.Article.Collection
Artlist.published = new Artlist.Article.Collection
Artlist.trash     = new Artlist.Article.Collection

Artlist.index.on "add remove change:bucket", (event) ->
  console.info "Article added or removed from index"
  Artlist.pending.set   (Artlist.index.select (article) -> article.isPending()), {remove:yes}
  Artlist.published.set (Artlist.index.select (article) -> article.isPublished()), {remove:yes}
  Artlist.trash.set     (Artlist.index.select (article) -> article.isTrash()), {remove:yes}

class Artlist.Article.DateCollection extends Artlist.Article.Collection
  constructor: (@date) ->
    Artlist.Article.Collection::constructor.call(this)
    @syncArticlesWithPublishedBucket()
    Artlist.published.on "add remove", @syncArticlesWithPublishedBucket

  syncArticlesWithPublishedBucket: =>
    @set Artlist.published.filterByDate(@date), {remove:yes}

# Search articles by query and category.

class Artlist.Article.Selection extends Artlist.Article.Collection
  initialize: ->
    @filters = new Backbone.Model {query: undefined, categories: [], range: @rangeOfDates() }
    @filters.on "change", => @set Artlist.search(@filters.toJSON()), {remove:yes}
    @set Artlist.search(@filters.toJSON())

  rangeOfDates: (now=Date.now())->
    Moment(now).add(amount, "day").format("YYYY-MM-DD") for amount in [0...25]

Artlist.search = (params={}) ->
  selection = Artlist.published.toArray()
  if params.query
    queryPattern = new RegExp params.query, "i"
    selection = selection.filter (article) -> filterByQueryPattern(article, queryPattern)
  if params.categories.length
    categories = params.categories
    selection = selection.filter (article) -> filterByCategory(article, categories)
  return selection

filterByQueryPattern = (article, queryPattern) ->
  for attribute in ["title", "venue"]
    return yes if queryPattern.test(article.get(attribute))
  return no

filterByCategory = (article, categories) ->
  for category in categories
    return yes if article.get("category") is category
  return no

# The operator might be permitted to edit THE ARTLIST if they have a valid permit.

Artlist.operator = extend {}, Backbone.Events

Artlist.operator.isPermittedToMakeChanges = ->
  @permit?.has("id")

Artlist.operator.grantPermissionToMakeChanges = (permit) ->
  Artlist.operator.permit = permit
  Artlist.operator.trigger("change:permit")

Artlist.operator.releasePermit = ->
  Artlist.operator.permit = undefined
  Artlist.operator.trigger("change:permit")

# A permit grants authorization to edit THE ARTLIST.

class Artlist.Permit extends Backbone.Model
  defaults: {id: "editor@artlist"}
  url: "/permit"
