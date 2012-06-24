#= require '_dop'
#= require '_jquery'
#= require '_selectivizr'
#= require '_jquery.easing'
#= require '_jquery.ui.core'
#= require '_jquery.ui.position'
#= require '_jquery.ui.widget'
#= require '_jquery.ui.tabs'
#= require '_jquery.ui.dialog'
#= require '_jquery.loginform'
#= require '_jquery.twosidedmultiselect'
#= require '_jquery.form'
#= require '_jquery.accordion'
#= require '_jquery.qtip'
#= require '_multiselect'
#= require '_jquery.masonry'

$(document).ready ->
  $('.effs').p2acc
    autoStart: true,
    slideInterval: 5000,
    slideNum:false
  $('#header select').each (index, element) =>
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



  # $(document).on 'click', '.selclose', (e) ->
  #   holder = $(@).parents('.multiSelectOptions:visible')
  #   holder.css('visibility': 'hidden')

  #   e.preventDefault()
  #   e.stopPropagation()

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

  # $('.contents input.formtip').tipsy
  #   fade: true
  #   gravity: 'w'
  #   html: false
  #   live: true
  #   offset: 5
  #   trigger: 'focus'
  #   opacity: 1

  formtip = $('.formtip')
  formtip.each (index, tip)->
    $tip = $(tip)
    text = $tip.attr('placeholder')
    title = $tip.attr('title')
    $tip.attr('placeholder', '')

    $('<a />').addClass('questiontip right').insertAfter($tip).text('?').attr('title', title).attr('tipcontents', text)
    $tip.next('a.questiontip').qtip
      position:
        my: 'bottom left'
        at: 'top center'
      content:
        text: (api) ->
          $(this).attr('tipcontents')
        title:
          text: title
      style:

        classes: 'ui-tooltip-blue'
  $('cbSalary').change ->
    changeSalary()

  $('table').on 'click', 'input:checkbox', (e)->
    etarget = $(e.target)
    target = etarget.attr('class')+' '+etarget.attr('id')+' '+etarget.attr('rel')
    if(target.indexOf('check_all') >= 0) and (etarget.parent('th').length > 0)
      otherInput = $(e.delegateTarget).find('td input:checkbox')
      if etarget.is(':checked') then otherInput.attr('checked', 'checked') else otherInput.removeAttr('checked')

  $('.search-cate').masonry
    itemSelector: '.cate'

  #$('.lkn').click (e)=>

    #formitems = $('.kinhnghiem').find('input, select, textarea')
    #formdatas = formitems.fieldValue()
    #tmpdatas = {}

    #for formdata, i in formdatas
      #key = "key"+i
      #tmpdatas[key] = formdata? or ' '

    #formitems.clearFields()

    #console.log tmpdatas
    #rowfn = doP.template($('#rowtmpl').text(), undefined, tmpdatas)

    #tablekn = $('table#kn').show().append(rowfn);

    #false
