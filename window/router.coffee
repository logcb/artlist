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
    document.title = "THE ARTLIST"
    document.body.classList.add("index")
    document.body.querySelector("h1").innerHTML = """<a href="/">THE ARTLIST</a>"""
    $(document).off "scroll", @returnToIndexWhenListIsInView
    window.scrollTo(0,0)

  intro: ->
    console.info "Rendering intro"
    document.title = "THE ARTLIST: INFORMATION"
    document.body.classList.remove("index")
    document.body.querySelector("h1").innerHTML = """<a href="/">THE ARTLIST</a>"""
    new ReadIntroView
    window.scrollTo(0,0)
    $(document).on "scroll", @returnToIndexWhenListIsInView

  post: () ->
    console.info "Rendering post an event", @params()
    document.title = "Post an event to THE ARTLIST"
    document.body.classList.remove("index")
    document.body.querySelector("h1").innerHTML = """<a href="/">THE ARTLIST</a>"""
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
