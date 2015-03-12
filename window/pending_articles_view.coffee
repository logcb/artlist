BasicView = require "./basic_view"
ArticleView = require "./article_view"

class PendingArticlesView extends BasicView
  module.exports = this

  el: "div.pending_articles"

  template: require "../templates/pending_articles.html"

  events:
    "click article:not(.activated)": "activateArticle"

  initialize: ->
    @collection.on "add remove", @render
    Artlist.operator.on "change:permit", @render
    @render()

  render: =>
    if Artlist.operator.isPermittedToMakeChanges()
      @el.classList.add "enabled"
      @el.classList.remove "disabled"
      @el.innerHTML = @renderTemplate articles: @collection.toArray()
    else
      @el.classList.remove "enabled"
      @el.classList.add "disabled"
      @el.innerHTML = ""

  activateArticle: (event) ->
    new ArticleView el: event.currentTarget
