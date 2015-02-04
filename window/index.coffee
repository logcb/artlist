# Like setTimeout but with more elegant syntax I think.
Function.delay = (amount, procedure) -> setTimeout procedure, amount

# Configure Backbone to use `window.$` defined by Zepto.
Backbone = require "backbone"
Backbone.$ = window.$

Artlist = require "./artlist"
Router  = require "./router"

# Set a reference to Artlist on the window object to receive index data and for convenience in the console.
window.Artlist = Artlist

# Construct the router and start the push state history system when the document is ready.
$(document).ready ->
  window.router = new Router
  window.router.on "route", -> console.info(arguments)
  Backbone.history.start {pushState: true}, {hashChange: false}

# Dispatch local hyperlinks to the router via history.
$(document).on "click", "a[href]", (event) ->
  location = new URL(event.currentTarget.href)
  if location.hostname is window.location.hostname
    event.preventDefault()
    path = event.currentTarget.getAttribute("href")
    window.router.navigate(path, {trigger: yes})
  else
    "Opening link to remote host..."

# TODO: Move this procedure into appropriate views.
$(document).on "scroll", (event) ->
  if document.body.classList.contains("index")
    # do nothing
  else
    if window.scrollY > ($("div.list_container").offset().top - $("body > header").height())
      event.preventDefault()
      window.router.navigate "/", {trigger: yes}
      window.scrollTo(0,0)
