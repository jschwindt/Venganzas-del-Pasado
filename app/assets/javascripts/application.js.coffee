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

window.open_player = (url) ->
  nw = window.open url, 'player', 'height=235,width=580,status=0,menubar=0,location=0,toolbar=0,scrollbars=0'
  if window.focus
    nw.focus()
  return false
