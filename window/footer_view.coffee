Backbone = require "backbone"
Artlist = require "./artlist"

class FooterView extends Backbone.View
  module.exports = this

  el: "body > footer"

  events:
    "click a.enter": "enterElementWasActivated"
    "submit form.new.permit": "permitFormWasCommitted"
    "click a.exit": "exitElementWasActivated"

  initialize: ->
    if Artlist.operator.isPermittedToMakeChanges()
      @el.querySelector("div.editor.controls").classList.add("activated")

  enterElementWasActivated: (event) ->
    event.preventDefault()
    @el.querySelector("div.editor.controls").classList.add("activated")
    @el.querySelector("div.editor.controls").scrollIntoView()
    @focusSecretPhraseInput()

  permitFormWasCommitted: (event) ->
    event.preventDefault()
    (new Artlist.Permit).save @permitInput(), {success: @permitIsReady, error: @permitError}

  permitIsReady: (permit) =>
    Artlist.operator.grantPermissionToMakeChanges(permit)
    @disableSecretPhraseInput()
    @secretPhraseInput().classList.remove "unacceptable"

  permitError: =>
    @focusSecretPhraseInput()
    @secretPhraseInput().classList.add "unacceptable"

  exitElementWasActivated: (event) ->
    event.preventDefault()
    Artlist.operator.permit.destroy success: @permitWasDestroyed

  permitWasDestroyed: =>
    Artlist.operator.releasePermit()
    @el.querySelector("form").reset()
    @focusSecretPhraseInput()

  secretPhraseInput: ->
    @el.querySelector("input.secret_phrase")

  permitInput: ->
    {"secret_phrase": @secretPhraseInput().value.trim()}

  focusSecretPhraseInput: ->
    @secretPhraseInput().disabled = false
    @secretPhraseInput().focus()

  disableSecretPhraseInput: ->
    @secretPhraseInput().blur()
    @secretPhraseInput().disabled = true
