//= require jquery
//= require jquery_ujs
//= require bootstrap-alerts
//= require bootstrap-dropdown
//= require jquery.jplayer
//= require jplayer
//= require_self

jQuery ->
  $(".alert-message").alert()
  $('.topbar').dropdown()
  $('.widget .archive .year > a').click (event) ->
    months = $(this).next()
    if months.is ':visible'
      months.slideUp()
    else
      months.slideDown()
    return false
