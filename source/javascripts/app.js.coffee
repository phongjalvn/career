#= require '_cssfx'
#= require '_jquery'
#= require '_selectivizr'
#= require '_jquery.easing'
#= require '_jquery.ui.core'
#= require '_jquery.ui.position'
#= require '_jquery.ui.widget'
#= require '_jquery.ui.tabs'
#= require '_jquery.ui.dialog'
#= require '_jquery.loginform'
#= require '_jquery.multiSelect'
#= require '_jquery.twosidedmultiselect'
#= require '_jquery.tipsy'

$(document).ready ->
  $('#banner li:first').addClass('active')
  $('#banner').click (e) ->
    $('li', $(@)).removeClass('active')
    $(e.target).closest('li').addClass('active')

  $('#header select, #search select').each (index, element) =>
    ele = $(element)
    ele.parent().addClass('select')
    title = $('option:selected', ele).text()
    title or= $('option:first', ele).text()
    ele.css
      'z-index':10
      'opacity':0
    .after('<span>'+title+'</span>')
    .change ->
      title = $('option:selected', ele).text()
      ele.next().text(title)

 
  
  $(document).on 'click', '.xbutton', (e) ->
    holder = $('.multiSelectOptions:hidden')
    if holder.length?
      holder.hide()
    e.preventDefault()
    e.event.stopPropagation()

   $('.xbutton').click ->
    $(document).trigger 'click'

  $('#search .container').tabs()

  $('#check_all').change ->
    checked = $('#check_all:checked').length ? true : false
    if checked
      $(@).parents('table').find('td input').attr('checked', true)
    else
      $(@).parents('table').find('td input').removeAttr('checked')
      
  $('#doitac li').each (index, element) ->
    ele = $(element)
    img = $('img', ele)
    imgsrc = img.attr('src').replace('.','-bw.')
    ele.css
      'background': 'url('+imgsrc+')'
    img.hover (
      ->
        $(@).addClass("hover")
      ->
        $(@).remove("hover")
    )

  $('.jslider').each ->
    slider = $(@)
    filler = $('.filler', slider)
    tooltip = $('.tooltip', slider)
    tooltip.css
      'margin-left': - tooltip.width() / 2
    total = slider.attr('total')
    current = slider.attr('current')
    step = slider.width() / total
    currentPos = step * current
    filler.width(currentPos)

  $('.contents input').tipsy
    fade: true
    gravity: 's'
    html: false
    live: true
    offset: 5
    title: 'placeholder'
    trigger: 'focus'
    opacity: 1

