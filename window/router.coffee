Backbone = require "backbone"
Artlist = require "./artlist"
# ReadIntroView = require "./read_intro_view"
# WriteArticleView = require "./write_article_view"

class Router extends Backbone.Router
  module.exports = this

  routes: {"": "index", "intro": "intro", "post": "post"}

  initialize: ->
    @bookmarks = $("section.intro, section.post, div.list.controls").toArray()
    $(document).on "click", "a[href^='/']", @localHyperlinkWasActivated
    $(document).on "scroll", @documentWasScrolled
    @on "route", (bookmark) -> console.info "Routed to #{bookmark}"
    @once "route", -> document.body.classList.remove("loading")

  scrollTo: (section) ->
    window.scrollTo 0, $(section).offset().top - $("body > header").height()

  index: ->
    console.info "Rendering index", @params()
    document.body.classList.add("index")
    @scrollTo("div.list.controls")

  intro: ->
    console.info "Rendering intro"
    document.body.classList.remove("index")
    @scrollTo("section.intro")

  post: () ->
    console.info "Rendering post an event", @params()
    document.body.classList.remove("index")
    @scrollTo("section.post")

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

  documentWasScrolled: (event) =>
    # console.info window.scrollY, $("section.intro").offset().top
    # console.info window.scrollY, $("section.post").offset().top
    # filtered = @bookmarks.filter (bookmark) -> window.scrollY >= ($(bookmark).offset().top - $("body > header").height())
    # console.info filtered

  returnToIndexWhenListIsInView: (event) =>
    if window.scrollY > ($("div.list_container").offset().top - $("body > header").height())
      event.preventDefault()
      $(document).off "scroll", @returnToIndexWhenListIsInView
      @navigate "/", {trigger: yes}
