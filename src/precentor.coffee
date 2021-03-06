'use strict'

((document) ->
  dom = document

  # SETUP
  precentor = (obj) ->
    noElErr = -> console.error('Precentor was initialized without elements.'); return
    optEls = obj.elements || obj.element
    return noElErr() unless optEls
    rawEls = []; els = []
    pushRawEls = (e) ->
      if _isStr(e) then rawEls.push({el: e, opts: null})
      else el = _topKeyOfObj(e); rawEls.push({el: el, opts: (e[el] || null)})
    if _isAry(optEls) then (pushRawEls(e) for e in optEls) else pushRawEls(optEls)
    for el in rawEls
      if (domEls = _getEl(el.el))
        (if _isElAry(domEls) then (els.push(el: de, opts: el.opts) for de in domEls) else els.push(el: domEls, el.opts))
    return noElErr() if els.length == 0
    settings = obj.settings || {}
    (new Precentor(el, settings)) for el in els when el
    return

  # Precentor Class
  class Precentor
    constructor: (@elObj, opts) ->
      @opts = _extObj({}, opts)
      @inst = _randar()
      @el = @elObj.el
      @wfNodes = {}
      @buildOpts()
      @buildEls()

    buildOpts: =>
      _extObj(@opts, @elObj.opts)
      elDataSet = @el.dataset
      normalize = (k, v) => @opts[k.replace(/^precent(.)(.*)/, (a, b, c)-> b.toLowerCase() + c)] = v; return
      normalize(k, v) for k, v of elDataSet

    buildEls: =>
      (@target = dom.createElement('span')).className = 'precentor-target'
      @el.parentNode.insertBefore(@target, @el)
      @target.appendChild(@el)
      @target.insertAdjacentHTML 'beforeend', _domStr(
        tag: 'div'
        attrs:
          id: "wrap_#{@inst}"
          class: 'precentor-wrapper'
          style: "z-index: #{_val(@opts.zIndex, 2100)};"
        children: [
          tag: 'div'
          attrs:
            class: 'precentor-inner'
          children: [
            tag: 'div'
            attrs:
              class: 'wf-add-form'
              id: "wf_add_form_#{@inst}"
              style: 'display: none;'
          ,
            tag: 'button'
            attrs:
              class: 'wf-add-btn'
              id: "wf_add_btn_#{@inst}"
            inner: 'Add Workflow Step'
          ]
        ]
      )
      @wrapper = dom.getElementById("wrap_#{@inst}")
      @wfAddBtn = dom.getElementById("wf_add_btn_#{@inst}")
      return

    wfNode: =>
      @wrapper.insertAdjacentHTML 'beforeend', _domStr(
        tag: 'div'
        attrs:
          id: "wrap_#{@inst}"
          class: 'wf-node'
        children: []
      )

  # HELPERS
  _val = (p, d) -> return if p in [false, 'false', 0, '0'] then p else p || d
  _bitify = (p, d) -> return if p in [false, 'false', 0, '0'] then 0 else if p in [true, 'true', '1', 1] then 1 else d
  _boolify = (p, d) -> return if p in [false, 'false', 0, '0'] then false else !!p || d
  _domStr = (o) ->
    attrs = ''; children = '';
    ((attrs += ' ' + k + '="' + v + '"') for k, v of o.attrs) if o.attrs
    ((children += if _isObj(c) then _domStr(c) else c) for c in o.children) if o.children
    return '<' + o.tag + attrs + '>' + (o.inner || children) + '</' + o.tag + '>'
  _extObj = (baseObj, extObj) -> (baseObj[k] = v) for k, v of extObj; return baseObj
  _isStr = (obj) -> return typeof obj == 'string'
  _isAry = (obj) -> return obj instanceof Array
  _isElAry = (obj) -> return obj instanceof HTMLCollection
  _isObj = (obj) -> return obj != null && typeof obj == 'object'
  _topKeyOfObj = (obj) -> return k for k, v of obj
  _getEl = (el) ->
    els = if el.charAt(0) == '#' then dom.getElementById(el.substr(1)) else dom.getElementsByClassName(el.substr(1))
    return if _isAry(els) && els.length == 0 then null else els
  _randar = -> (Math.random().toString(36).slice(2) + Math.random().toString(36).slice(2)).substring(0, 16)
  _prepHex = (hex) -> nex = hex.replace(/^#/, ''); return if nex.length == 3 then "#{nex}#{nex}" else nex
  _fullHex = (hex) -> return if hex == 'transparent' then hex else "#" + _prepHex(hex)
  _cc = (hex) ->
    r: parseInt((_prepHex(hex)).substring(0, 2), 16)
    g: parseInt((_prepHex(hex)).substring(2, 4), 16)
    b: parseInt((_prepHex(hex)).substring(4, 6), 16)

  # INIT
  window.precentor = precentor
  return

) document
