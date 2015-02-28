# Configure Backbone to use `window.$` defined by Zepto.
Backbone = require "backbone"
Backbone.$ = window.$
# Similar to setTimeout but with more elegant syntax I find.
Function.delay = (amount, procedure) -> setTimeout procedure, amount


# Define a reference to Artlist on the window to receive index data and for convenience in the console.
Artlist = window.Artlist = require "./artlist"


# Construct an editing permit for the operator if a permit id is included in the document.
$(document).ready ->
  if permitIdentifier = document.body.getAttribute("data-permit-id")
    permit = new Artlist.Permit id:permitIdentifier
    Artlist.operator.grantPermissionToMakeChanges(permit)


# Define a selection of articles for this session after the index data has been initialized.
$(document).ready ->
  Artlist.selection = new Artlist.Article.Selection

# Construct persistent views when the document is ready.
$(document).ready ->
  BodyView = require "./body_view"
  new BodyView
  ListControlsView = require "./list_controls_view"
  new ListControlsView model: Artlist.selection.filters
  SelectedArticlesView = require "./selected_articles_view"
  new SelectedArticlesView collection: Artlist.selection
  PendingArticlesView = require "./pending_articles_view"
  new PendingArticlesView collection: Artlist.pending
  TrashedArticlesView = require "./trashed_articles_view"
  new TrashedArticlesView collection: Artlist.trash
  FooterView = require "./footer_view"
  new FooterView

# Construct the router and start the push state history system when the document is ready.
$(document).ready ->
  Router = require "./router"
  Artlist.router = new Router
  Backbone.history.start {pushState: true}

# Say hello to console operators.
$(document).ready ->
  console.info "THE ARTLIST is ready at #{location.hostname}:#{location.port}"
