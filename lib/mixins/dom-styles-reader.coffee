Mixin = require 'mixto'

module.exports =
class DOMStylesReader extends Mixin
  @domStylesCache: {}
  
  # Internal: This function insert a dummy element in the DOM to compute
  # its style, return the specified property, and remove the element
  # from the DOM.
  #
  # scopes - An {Array} of {String} reprensenting the scope to reproduce.
  # property - The property {String} name.
  #
  # Returns a {String} of the property value.
  retrieveStyleFromDom: (scopes, property, shadowRoot=true) ->
    key = scopes.join(' ')

    if @constructor.domStylesCache[key]?[property]?
      return @constructor.domStylesCache[key][property]

    @ensureDummyNodeExistence(shadowRoot)
    @constructor.domStylesCache[key] ?= {}

    parent = @dummyNode
    for scope in scopes
      node = document.createElement('span')
      # css class is the scope without the dots,
      # see pushScope @ atom/atom/src/lines-component.coffee
      node.className = scope.replace(/\.+/g, ' ')
      parent.appendChild(node) if parent?
      parent = node

    value = getComputedStyle(parent).getPropertyValue(property)
    @dummyNode.innerHTML = ''

    @constructor.domStylesCache[key][property] = value

  # Internal: Creates a DOM node container for all the operations that
  # need to read styles properties from DOM.
  ensureDummyNodeExistence: (shadowRoot) ->
    unless @dummyNode?
      @dummyNode = document.createElement('span')
      @dummyNode.style.visibility = 'hidden'
    if shadowRoot
      @editorView.shadowRoot.appendChild(@dummyNode)
    else
      @editorView.appendChild(@dummyNode)

  invalidateCache: ->
    @constructor.domStylesCache = {}
