Artlist = require "./artlist"
ArticleView = require "./article_view"
Backbone = require "backbone"
Moment = require "moment"

class ArticleListView extends Backbone.View
  module.exports = this

  events:
    "mousedown article.compacted[id]": "activateArticle"

  initialize: ->
    @collection = Artlist.index
    @collection.on "add", @render
    @collection.on "remove", @render
    @render()

  render: =>
    sections = []
    template = require "../templates/day_of_articles.html"
    for date, articles of @getArticlesGroupedByDate()
      articles = (article.toJSON() for article in articles)
      sections.push template({date: date, articles: articles, moment: Moment})
    @el.innerHTML = sections.join("")

  activateArticle: (event) ->
    id = event.currentTarget.id
    article = @collection.get(id)
    new ArticleView {model: article, el: event.currentTarget}

  getArticlesGroupedByDate: ->
    @collection.groupBy (article) -> article.get("date")
