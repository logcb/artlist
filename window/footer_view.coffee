Backbone = require "backbone"
Artlist = require "./artlist"

class FooterView extends Backbone.View
  module.exports = this

  el: "body > footer"

  initialize: ->
    @permit = new Artlist.Permit

  events:
    "click a.enter": "enterElementWasActivated"
    "submit form.new.permit": "permitFormWasCommitted"
    "click a.exit": "exitElementWasActivated"

  secretPhraseInput: ->
    @el.querySelector("input.secret_phrase")

  permitInput: ->
    {"secret_phrase": @secretPhraseInput().value.trim()}

  enterElementWasActivated: (event) ->
    event.preventDefault()
    @el.querySelector("div.editor.controls").classList.add("activated")
    @el.querySelector("div.editor.controls").scrollIntoView()
    @secretPhraseInput().disabled = false
    @secretPhraseInput().focus()

  permitFormWasCommitted: (event) ->
    event.preventDefault()
    @secretPhraseInput().classList.remove "unacceptable"
    @permit.save @permitInput(), {success: @permitIsReady, error: @permitError}

  permitIsReady: =>
    @secretPhraseInput().blur()
    @secretPhraseInput().disabled = true
    document.body.classList.add("editing")

  permitError: =>
    @secretPhraseInput().disabled = false
    @secretPhraseInput().focus()
    @secretPhraseInput().classList.add "unacceptable"

  exitElementWasActivated: (event) ->
    event.preventDefault()
    @permit.destroy success: @permitWasDestroyed

  permitWasDestroyed: =>
    document.body.classList.remove("editing")
    @el.querySelector("form").reset()
    @secretPhraseInput().disabled = false
    @secretPhraseInput().focus()
    delete @permit
    @initialize()
