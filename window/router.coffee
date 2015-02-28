Backbone = require "backbone"
Artlist = require "./artlist"
ReadIntroView = require "./read_intro_view"
WriteArticleView = require "./write_article_view"

class Router extends Backbone.Router
  module.exports = this

  routes: {"": "index", "intro": "intro", "post": "post"}

  initialize: ->
    $(document).on "click", "a[href^='/']", @localHyperlinkWasActivated
    @on "route", (bookmark) -> console.info "Routed to #{bookmark}"
    @once "route", -> document.body.classList.remove("loading")

  index: ->
    console.info "Rendering index", @params()
    document.body.classList.add("index")
    $(document).off "scroll", @returnToIndexWhenListIsInView
    window.scrollTo(0,0)

  intro: ->
    console.info "Rendering intro"
    document.body.classList.remove("index")
    new ReadIntroView
    window.scrollTo(0,0)
    $(document).on "scroll", @returnToIndexWhenListIsInView

  post: () ->
    console.info "Rendering post an event", @params()
    document.body.classList.remove("index")
    article = new Artlist.Article
    new WriteArticleView model: article
    window.scrollTo(0,0)
    $(document).on "scroll", @returnToIndexWhenListIsInView

  params: (url=window.location) ->
    params = {}
    if url.search
      for pair in url.search.replace("?", "").split("&")
        [name, value] = pair.split("=")
        params[name] = decodeURIComponent value
    return params

  localHyperlinkWasActivated: (event) =>
    event.preventDefault()
    @navigate event.currentTarget.getAttribute("href"), {trigger: yes}

  returnToIndexWhenListIsInView: (event) =>
    if window.scrollY > ($("div.list_container").offset().top - $("body > header").height())
      event.preventDefault()
      $(document).off "scroll", @returnToIndexWhenListIsInView
      @navigate "/", {trigger: yes}
