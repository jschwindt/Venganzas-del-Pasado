//= require jquery
//= require jquery_ujs
//= require bootstrap-alerts
//= require bootstrap-dropdown
//= require bootstrap-twipsy
//= require bootstrap-popover
//= require jquery.jplayer
//= require jplayer
//= require flash_player
//= require jquery.timeago
//= require jquery.timeago-es
//= require_self

jQuery ->
  $(".alert-message").alert()
  $("abbr.timeago").timeago();
  $('.topbar').dropdown()
  $('.widget .archive .year > a').click (event) ->
    months = $(this).next()
    if months.is ':visible'
      months.slideUp()
    else
      months.slideDown()
    return false
  $('.open_player').click (event) ->
    open_player this.href
    return false

  enterTimer = 0

  $('.like-popover').hover (event) ->
    if event.type == 'mouseenter'
      enterTimer = setTimeout ( =>
        $.get $(this).data('popover-url'), (data) =>
          if data.length > 0
            $(this).popover
              trigger: 'manual'
              html: true
              animate: true
              placement: 'above'
              offset: 18
              template: '<div class="arrow"></div><div class="inner"><div class="content"><p></p></div></div>'
              content: ->
                data
            $(this).popover('show')
      ), 1500
    else if event.type == 'mouseleave'
      clearTimeout(enterTimer)
      $(this).popover('hide')

window.open_player = (url) ->
  nw = window.open url, 'player', 'height=235,width=580,status=0,menubar=0,location=0,toolbar=0,scrollbars=0'
  if window.focus
    nw.focus()
  return false
