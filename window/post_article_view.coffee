BasicView = require "./basic_view"

class PostArticleView extends BasicView
  module.exports = this

  el: "body > div.post"

  initialize: ->
    @constructNewArticle()
    @render()

  constructNewArticle: ->
    @article = new Artlist.Article
    @article.on "invalid", @focusInvalidAttribute
    @article.on "sync", => @$("form").addClass("synced")
    @article.on "sync", => Artlist.index.add(@article)
    @article.on "sync", => Artlist.router.navigate("/", {trigger: yes})
    @article.on "sync", => Function.delay 5000, => @initialize()

  events:
    "input div.attribute": "attributeInputWasChanged"
    "submit": "formWasSubmitted"

  render: =>
    template = require "../templates/post_article.html"
    @el.innerHTML = template({@formatModelTimeForInput, @hasPostedAnArticle, article: @article.toJSON()})

  activate: =>
    @el.querySelector("input[name=title]").focus()

  deactivate: =>
    $(@el).off()

  commit: (event) ->
    if @article.save()
      @disableFormInput()
      @hasPostedAnArticle = yes

  disableFormInput: ->
    @$("input,select,textarea").toArray().forEach (el) -> el.disabled = yes

  enableFormInput: ->
    @$("input,select,textarea").toArray().forEach (el) -> el.disabled = no

  attributeInputWasChanged: (event) ->
    value = event.target.value.trim()
    if event.target.name is "time"
      if parsedValue = @parseInputTimeForModel(value)
        @article.set event.target.name, parsedValue
    else
      @article.set event.target.name, value

  formWasSubmitted: (event) ->
    event.preventDefault()
    @commit(event)

  focusInvalidAttribute: (article, error) =>
    [attributeName, message] = error
    console.error "Article #{attributeName} #{message}."
    @el.querySelector("input[name=#{attributeName}],textarea[name=#{attributeName}]").focus()
