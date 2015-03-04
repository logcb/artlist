{extend} = require "underscore"
Backbone = require "backbone"
Moment = require "moment"

module.exports = Artlist = {}

# Each event on THE ARTLIST is represented by an instance of the Article class.

class Artlist.Article extends Backbone.Model
  urlRoot: "/articles"

  isPending: ->
    (@get("published_at") is undefined) and @isNotTrash()

  isPublished: ->
    (@get("published_at") isnt undefined) and @isNotTrash()

  isTrash: ->
    @get("trashed_at") isnt undefined

  isNotTrash: ->
    @isTrash() is no

  defaults: ->
    date: Moment(Date.now()).format("YYYY-MM-DD")
    time: "16:30"
    category: "Community"
    cost: "Free"

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

Artlist.index.on "all", (event) ->
  Artlist.pending.set   Artlist.index.select (article) -> article.isPending()
  Artlist.published.set Artlist.index.select (article) -> article.isPublished()
  Artlist.trash.set     Artlist.index.select (article) -> article.isTrash()

class Artlist.Article.DateCollection extends Artlist.Article.Collection
  constructor: (@date, options={}) ->
    Artlist.Article.Collection::constructor.call(this)
    @source = options.source ? Artlist.index
    @set @source.filterByDate(@date)
    @source.on "add remove", => @set @source.filterByDate(@date)

# Search articles by query and category.

class Artlist.Article.Selection extends Artlist.Article.Collection
  initialize: ->
    @filters = new Backbone.Model {query: undefined, categories: [], range: @rangeOfDates() }
    @filters.on "change", => @set Artlist.search(@filters.toJSON()), {remove:yes}
    @set Artlist.search(@filters.toJSON())

  rangeOfDates: (now=Date.now())->
    Moment(now).add(amount, "day").format("YYYY-MM-DD") for amount in [-15...15]

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
