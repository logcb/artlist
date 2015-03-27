Backbone = require "backbone"

class BodyView extends Backbone.View
  module.exports = this

  el: "body"

  events:
    "click nav.intro img": "toggleIntroSection"
    "click nav.share img": "togglePostSection"

  initialize: ->
    @render()
    Artlist.operator.on "change:permit", @render
    $(window).on "scroll", @documentWasScrolled

  render: =>
    if Artlist.operator.isPermittedToMakeChanges()
      @el.classList.add("editing")
    else
      @el.classList.remove("editing")

  documentWasScrolled: =>
    if window.scrollY > ($("div.current_articles").offset().top - $("body > header").height())
      $("div.filter.controls").addClass("fixed")
    else
      $("div.filter.controls").removeClass("fixed")

  togglePostSection: (event) ->
    event.preventDefault()
    if document.body.querySelector("div.post").hasAttribute("hidden")
      document.body.querySelector("div.post").removeAttribute("hidden")
      window.scrollTo 0, $("div.post").offset().top - $("body > header").height()
    else
      document.body.querySelector("div.post").setAttribute("hidden", yes)

  toggleIntroSection: (event) ->
    event.preventDefault()
    if document.body.querySelector("div.intro").hasAttribute("hidden")
      document.body.querySelector("div.intro").removeAttribute("hidden")
      window.scrollTo 0, $("div.intro").offset().top - $("body > header").height()
    else
      document.body.querySelector("div.intro").setAttribute("hidden", yes)
