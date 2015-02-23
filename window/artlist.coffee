Backbone = require "backbone"
Moment = require "moment"

module.exports = Artlist = {}

Artlist.Article = class Article extends Backbone.Model
  urlRoot: "/articles"

  defaults: ->
    date: Moment(Date.now()).format("YYYY/MM/DD")
    time: "16:30"
    category: "Community"

  validate: (attributes, options) ->
    if attributes.title is undefined
      return ["title", "can’t be blank"]
    if attributes.venue is undefined
      return ["venue", "can’t be blank"]
    if attributes.address is undefined
      return ["address", "can’t be blank"]
    if attributes.date is undefined
      return ["date", "can’t be blank"]
    if attributes.time is undefined
      return ["time", "can’t be blank"]


class Article.Collection extends Backbone.Collection
  model: Article

Artlist.search = (params={}) ->
  selection = Artlist.index.toArray()
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
