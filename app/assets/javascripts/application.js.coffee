//= require jquery
//= require jquery_ujs
//= require jquery.jplayer
//= require bootstrap
//= require jplayer
//= require flash_player
//= require jquery.timeago
//= require jquery.timeago-es
//= require_self

jQuery ->
  $("abbr.timeago").timeago();
  $('.open_player').click (event) ->
    open_player this.href
    return false

  
  $('.opinions-popover').click (event) ->
    $.get $(this).data('popover-url'), (data) =>
      if data.length > 0
        $(this).popover
          trigger: 'manual'
          html: true
          animate: true
          placement: 'top'
          offset: 18
          template: '<div class="arrow"></div><div class="inner"><div class="content"></div></div>'
          content: ->
            data
        $(this).popover('show')
    
    

window.open_player = (url) ->
  nw = window.open url, 'player', 'height=235,width=580,status=0,menubar=0,location=0,toolbar=0,scrollbars=0'
  if window.focus
    nw.focus()
  return false
