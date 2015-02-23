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
  Artlist.router = new Router
  Backbone.history.start {pushState: true}
