(($, window, document, undefined_) ->
  prop = (n) ->
    (if n and n.constructor is Number then n + "px" else n)
  $.fn.bgiframe = (if $.browser.msie and /msie 6\.0/i.test(navigator.userAgent) then (s) ->
    s = $.extend(
      top: "auto"
      left: "auto"
      width: "auto"
      height: "auto"
      opacity: true
      src: "javascript:false;"
    , s)
    html = "<iframe class=\"bgiframe\"frameborder=\"0\"tabindex=\"-1\"src=\"" + s.src + "\"" + "style=\"display:block;position:absolute;z-index:-1;" + (if s.opacity isnt false then "filter:Alpha(Opacity='0');" else "") + "top:" + (if s.top is "auto" then "expression(((parseInt(this.parentNode.currentStyle.borderTopWidth)||0)*-1)+'px')" else prop(s.top)) + ";" + "left:" + (if s.left is "auto" then "expression(((parseInt(this.parentNode.currentStyle.borderLeftWidth)||0)*-1)+'px')" else prop(s.left)) + ";" + "width:" + (if s.width is "auto" then "expression(this.parentNode.offsetWidth+'px')" else prop(s.width)) + ";" + "height:" + (if s.height is "auto" then "expression(this.parentNode.offsetHeight+'px')" else prop(s.height)) + ";" + "\"/>"
    @each ->
      @insertBefore document.createElement(html), @firstChild  if $(this).children("iframe.bgiframe").length is 0
   else ->
    this
  )
  $.fn.bgIframe = $.fn.bgiframe
  $.P2 ?= {}
  multiDropID = 0
  $.widget "P2.multiDrop",
    options:
      header: true
      footer: true
      main: true
      height: 10
      minWidth: 225
      classes: "six columns"
      checkAllText: "Check all"
      uncheckAllText: "Uncheck all"
      noneSelectedText: "Select options"
      selectedText: "# selected"
      selectedList: 1
      show: ""
      hide: ""
      autoOpen: false
      multiple: true
      position:
        my: "top"
        at: "bottom"
        collision: "none none"
    _create: ->
      el = @element.hide()
      o = @options
      @speed = $.fx.speeds._default
      @_isOpen = false
      drop = (@drop = $("<div class=\"custom dropdown\"></div>")).insertAfter(el)
      button = (@button = $("<div class=\"clear\" href=''></div>")).attr(
        title: el.attr("title")
        "aria-haspopup": true
        tabIndex: el.attr("tabIndex")
      ).appendTo(drop)
      buttonlabel = (@buttonlabel = $("<a />").addClass("current")).html(o.noneSelectedText).appendTo(button).after('<a class="selector" href="#"></a>')
      main = (@main = $("<ul />")).addClass("multiDropMain").appendTo(drop)
      header = (@header = $("<div />")).addClass("multiDropHeader clearfix").appendTo(main)
      headerLinkContainer = (@headerLinkContainer = $("<div />")).addClass("reset").html(->
        if o.header is true
          "<a class=\"multiDropAll\" href=\"#\"><span>" + o.checkAllText + "</span></a>"
        else if typeof o.header is "string"
          "<div>" + o.header + "</div>"
        else
          ""
      ).appendTo(header)
      checkboxContainer = (@checkboxContainer = $("<div />")).addClass("multiDrop reset").appendTo(main)
      footer = (@footer = $("<div />")).addClass("multiDropfooter").appendTo(main)
      footerLinkContainer = (@footerLinkContainer = $("<div />")).addClass("multiDropFooter clearfix reset").html(->
        if o.footer is true
          "<a class=\"multiDropNone\" href=\"#\"><span>" + o.uncheckAllText + "</span></a>"
        else if typeof o.footer is "string"
          "<div>" + o.footer + "</div>"
        else
          ""
      ).append("<a href=\"#\" class=\"close multiDropClose\">[X]</a>").appendTo(footer)
      header= (@header = header.add(footer))
      @_bindEvents()
      @refresh true
      main.addClass "multiDropSingle"  unless o.multiple

    _init: ->
      @header.hide()  if @options.header is false
      @headerLinkContainer.find(".multiDropAll, .multiDropNone").hide()  unless @options.multiple
      @open()  if @options.autoOpen
      @disable()  if @element.is(":disabled")

    refresh: (init) ->
      el = @element
      o = @options
      main = @main
      checkboxContainer = @checkboxContainer
      optgroups = []
      html = ""
      id = el.attr("id") or multiDropID++
      el.find("option").each (i) ->
        $this = $(this)
        parent = @parentNode
        title = @innerHTML
        description = @title
        value = @value
        inputID = "multiDrop-" + (@id or id + "-option-" + i)
        isDisabled = @disabled
        isSelected = @selected
        labelClasses = [ "" ]
        optLabel = undefined
        if parent.tagName is "OPTGROUP"
          optLabel = parent.getAttribute("label")
          if $.inArray(optLabel, optgroups) is -1
            html += "<li class=\"multiDrop-optgroup-label\"><a href=\"#\">" + optLabel + "</a></li>"
            optgroups.push optLabel
        labelClasses.push "disabled"  if isDisabled
        labelClasses.push "active"  if isSelected and not o.multiple
        html += "<li class=\"" + (if isDisabled then "multiDropDisabled" else "") + "\">"
        html += "<label for=\"" + inputID + "\" title=\"" + description + "\" class=\"" + labelClasses.join(" ") + "\">"
        html += "<input id=\"" + inputID + "\" name=\"multiDrop_" + id + "\" type=\"" + (if o.multiple then "checkbox" else "radio") + "\" value=\"" + value + "\" title=\"" + title + "\""
        if isSelected
          html += " checked=\"checked\""
          html += " aria-selected=\"true\""
        if isDisabled
          html += " disabled=\"disabled\""
          html += " ariaDisabled=\"true\""
        html += " /><span>" + title + "</span></label></li>"

      checkboxContainer.html html
      @labels = main.find("label")
      @inputs = @labels.children("input")
      @_setButtonWidth()
      @_setmainWidth()
      @button[0].defaultValue = @update()
      @_trigger "refresh"  unless init

    update: ->
      o = @options
      $inputs = @inputs
      $checked = $inputs.filter(":checked")
      numChecked = $checked.length
      value = undefined
      if numChecked is 0
        value = o.noneSelectedText
      else
        if $.isFunction(o.selectedText)
          value = o.selectedText.call(this, numChecked, $inputs.length, $checked.get())
        else if /\d/.test(o.selectedList) and o.selectedList > 0 and numChecked <= o.selectedList
          value = $checked.map(->
            $(this).next().html()
          ).get().join(", ")
        else
          value = o.selectedText.replace("#", numChecked).replace("#", $inputs.length)
      @buttonlabel.html value
      value

    _bindEvents: ->
      clickHandler = ->
        self[(if self._isOpen then "close" else "open")]()
        false
      self = this
      button = @button
      button.find("span").bind "click.multiDrop", clickHandler
      button.bind
        click: clickHandler
        keypress: (e) ->
          switch e.which
            when 27, 38, 37
              self.close()
            when 39, 40
              self.open()

        mouseenter: ->
          $(this).addClass "hover"  unless button.hasClass("disabled")

        mouseleave: ->
          $(this).removeClass "hover"

        focus: ->
          $(this).addClass "focus"  unless button.hasClass("disabled")

        blur: ->
          $(this).removeClass "focus"

      @header.delegate "a", "click.multiDrop", (e) ->
        if $(this).hasClass("multiDropClose")
          self.close()
        else
          self[(if $(this).hasClass("multiDropAll") then "checkAll" else "uncheckAll")]()
        e.preventDefault()

      @main.delegate("li.multiDrop-optgroup-label a", "click.multiDrop", (e) ->
        e.preventDefault()
        $this = $(this)
        $inputs = $this.parent().nextUntil("li.multiDrop-optgroup-label").find("input:visible:not(:disabled)")
        nodes = $inputs.get()
        label = $this.parent().text()
        return  if self._trigger("beforeoptgrouptoggle", e,
          inputs: nodes
          label: label
        ) is false
        self._toggleChecked $inputs.filter(":checked").length isnt $inputs.length, $inputs
        self._trigger "optgrouptoggle", e,
          inputs: nodes
          label: label
          checked: nodes[0].checked
      ).delegate("label", "mouseenter.multiDrop", ->
        unless $(this).hasClass("disabled")
          self.labels.removeClass "hover"
          $(this).addClass("hover").find("input").focus()
      ).delegate("label", "keydown.multiDrop", (e) ->
        e.preventDefault()
        switch e.which
          when 9, 27
            self.close()
          when 38, 40, 37, 39
            self._traverse e.which, this
          when 13
            $(this).find("input")[0].click()
      ).delegate("input[type=\"checkbox\"], input[type=\"radio\"]", "click.multiDrop", (e) ->
        $this = $(this)
        val = @value
        checked = @checked
        tags = self.element.find("option")
        if @disabled or self._trigger("click", e,
          value: val
          text: @title
          checked: checked
        ) is false
          e.preventDefault()
          return
        $this.focus()
        $this.attr "aria-selected", checked
        tags.each ->
          if @value is val
            @selected = checked
          else @selected = false  unless self.options.multiple

        unless self.options.multiple
          self.labels.removeClass "active"
          $this.closest("label").toggleClass "active", checked
          self.close()
        self.element.trigger "change"
        setTimeout $.proxy(self.update, self), 10
      ).delegate("input[type=\"checkbox\"], input[type=\"radio\"]", "change.multiDrop", (e) ->
      )
      $(document).bind "mousedown.multiDrop", (e) ->
        self.close()  if self._isOpen and not $.contains(self.main[0], e.target) and not $.contains(self.button[0], e.target) and e.target isnt self.button[0]

      $(@element[0].form).bind "reset.multiDrop", ->
        setTimeout $.proxy(self.refresh, self), 10

    _setButtonWidth: ->
      width = @element.outerWidth()
      o = @options
      width = o.minWidth  if /\d/.test(o.minWidth) and width < o.minWidth
      @button.width width

    _setmainWidth: ->
      o = @options
      m = @drop.add(@main)
      width = @button.outerWidth() - parseInt(m.css("padding-left"), 10) - parseInt(m.css("padding-right"), 10) - parseInt(m.css("border-right-width"), 10) - parseInt(m.css("border-left-width"), 10)
      m.width width or @button.outerWidth()

    _traverse: (which, start) ->
      $start = $(start)
      moveToLast = which is 38 or which is 37
      $next = $start.parent()[(if moveToLast then "prevAll" else "nextAll")]("li:not(.multiDropDisabled, .multiDrop-optgroup-label)")[(if moveToLast then "last" else "first")]()
      unless $next.length
        $container = @main.find("ul").last()
        @main.find("label")[(if moveToLast then "last" else "first")]().trigger "mouseover"
        $container.scrollTop (if moveToLast then $container.height() else 0)
      else
        $next.find("label").trigger "mouseover"

    _toggleState: (prop, flag) ->
      ->
        this[prop] = flag  unless @disabled
        if flag
          @setAttribute "aria-selected", true
        else
          @removeAttribute "aria-selected"

    _toggleChecked: (flag, group) ->
      $inputs = (if (group and group.length) then group else @inputs)
      self = this
      $inputs.each @_toggleState("checked", flag)
      $inputs.eq(0).focus()
      @update()
      values = $inputs.map(->
        @value
      ).get()
      @element.find("option").each ->
        self._toggleState("selected", flag).call this  if not @disabled and $.inArray(@value, values) > -1

      @element.trigger "change"  if $inputs.length

    _toggleDisabled: (flag) ->
      @button.attr(
        disabled: flag
        "ariaDisabled": flag
      )[(if flag then "addClass" else "removeClass")] "disabled"
      inputs = @main.find("input")
      key = "ech-multiDropDisabled"
      if flag
        inputs = inputs.filter(":enabled").data(key, true)
      else
        inputs = inputs.filter(->
          $.data(this, key) is true
        ).removeData(key)
      inputs.attr(
        disabled: flag
        "arialDisabled": flag
      ).parent()[(if flag then "addClass" else "removeClass")] "disabled"
      @element.attr
        disabled: flag
        "ariaDisabled": flag

    open: (e) ->
      self = this
      button = @button
      m = main = @main
      speed = @speed
      o = @options
      return  if @_trigger("beforeopen") is false or button.hasClass("disabled") or @_isOpen
      $container = @checkboxContainer
      effect = o.show
      pos = button.offset()

      if $.isArray(o.show)
        effect = o.show[0]
        speed = o.show[1] or self.speed

      if $.ui.position and not $.isEmptyObject(o.position)
        o.position.of = o.position.of or button
        main.show().position(o.position).hide().show effect, speed
      else
        main.css(
          top: pos.top + button.outerHeight()
          left: pos.left
        ).show effect, speed
      height = o.height * m.find('li').first().outerHeight() + parseInt(m.css("padding-top"), 10) + parseInt(m.css("padding-bottom"), 10) + parseInt(m.css("border-bottom-width"), 10) + parseInt(m.css("border-top-width"), 10)
      $container.scrollTop(0).css 'max-height', height

      @labels.eq(0).trigger("mouseover").trigger("mouseenter").find("input").trigger "focus"
      button.addClass "active"
      @_isOpen = true
      @_trigger "open"

    close: ->
      return  if @_trigger("beforeclose") is false
      o = @options
      effect = o.hide
      speed = @speed
      if $.isArray(o.hide)
        effect = o.hide[0]
        speed = o.hide[1] or @speed
      @main.hide effect, speed
      @button.removeClass("active").trigger("blur").trigger "mouseleave"
      @_isOpen = false
      @_trigger "close"

    enable: ->
      @_toggleDisabled false

    disable: ->
      @_toggleDisabled true

    checkAll: (e) ->
      @_toggleChecked true
      @_trigger "checkAll"

    uncheckAll: ->
      @_toggleChecked false
      @_trigger "uncheckAll"

    getChecked: ->
      @main.find("input").filter ":checked"

    destroy: ->
      $.Widget::destroy.call this
      @button.remove()
      @main.remove()
      @element.show()
      this

    isOpen: ->
      @_isOpen

    widget: ->
      @main

    getButton: ->
      @button

    _setOption: (key, value) ->
      main = @main
      switch key
        when "header"
          main.find("div.multiDropHeader")[(if value then "show" else "hide")]()
        when "checkAllText"
          main.find("a.multiDropAll span").eq(-1).text value
        when "uncheckAllText"
          main.find("a.multiDropNone span").eq(-1).text value
        when "height"
          main.find("ul").last().height parseInt(value, 10)
        when "minWidth"
          @options[key] = parseInt(value, 10)
          @_setButtonWidth()
          @_setmainWidth()
        when "selectedText", "selectedList", "noneSelectedText"
          @options[key] = value
          @update()
        when "classes"
          main.add(@button).removeClass(@options.classes).addClass value
        when "multiple"
          main.toggleClass "multiDropSingle", not value
          @options.multiple = value
          @element[0].multiple = value
          @refresh()
      $.Widget::_setOption.apply this, arguments

) jQuery, window, document
