Artlist = require "./artlist"
Backbone = require "backbone"

class ArticleListView extends Backbone.View
  module.exports = this

  events:
    "mousedown article[id]": "editArticle"

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
      sections.push template({date: date, articles: articles})
    @el.innerHTML = sections.join("")

  editArticle: (event) ->
    id = event.currentTarget.id
    Backbone.history.navigate("articles/#{id}")

  getArticlesGroupedByDate: ->
    @collection.groupBy (article) -> article.get("date")
