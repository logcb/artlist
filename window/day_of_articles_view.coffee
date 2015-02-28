BasicView = require "./basic_view"
ArticleView = require "./article_view"
Moment = require "moment"

class DayOfArticlesView extends BasicView
  module.exports = this
  tagName: "section"
  className: "day"
  template: require "../templates/day_of_articles.html"

  initialize: (@date, options={}) ->
    @collection = new Artlist.Article.DateCollection @date, options
    @collection.on "add", @insertArticle
    @collection.on "remove", @removeArticle
    @insertIntoDocument()

  events:
    "mousedown article.compacted[id]": "activateArticle"

  render: =>
    @el.id = @sectionID()
    @el.classList[if @collection.isEmpty() then "add" else "remove"]("empty")
    @el.innerHTML = @renderTemplate({
      date: @date
      articles: @collection.toArray()
    })

  insertIntoDocument: ->
    @render()
    referenceElement = document.querySelector("#{@nextSectionID()}, body > footer")
    document.body.insertBefore(@el, referenceElement)

  insertArticle: (article) =>
    @render()

  removeArticle: (article) =>
    @render()

  activateArticle: (event) ->
    new ArticleView
      model: @collection.get(event.currentTarget.id)
      el: event.currentTarget

  nextSectionID: ->
    @sectionID Moment(@date, "YYYY-MM-DD").add(1, "day")

  sectionID: (date=@date) ->
    "#" + Moment(date, "YYYY-MM-DD").format("MMMDD")

  articleID: (article) ->
    "#ART" + article.id
