//= require jquery
//= require jquery_ujs
//= require jquery.jplayer
//= require bootstrap
//= require jplayer
//= require flash_player
//= require jquery.timeago
//= require jquery.timeago-es
//= require socialite
//= require_self

jQuery ->
  $("abbr.timeago").timeago();
  $('.open_player').click (event) ->
    open_player this.href
    return false

  Socialite.widget 'facebook', 'likebox',
    init: (instance) ->
      el = document.createElement 'div'
      el.className = 'fb-like-box'
      Socialite.copyDataAttributes instance.el, el
      instance.el.appendChild el
      if window.FB && window.FB.XFBML
        window.FB.XFBML.parse instance.el

  Socialite.setup
    facebook:
      lang     : 'es_LA',
      appId    : '305139166173322'
      
  if window.innerWidth >= 768
    Socialite.load $('.facebook-likebox')[0]
    Socialite.activate $('.facebook-likebox')[0]
    Socialite.activate $('.twitter-timeline')[0]

  $('.post .share').hover (event) ->
    Socialite.load this
  
  $('.btn-opinions-popover').click (event) ->
    $this = $(this)
    if 'opened' != $this.data 'popover-status'
      $.get $this.data('popover-url'), (data) =>
        if data.length > 0
          $this.popover
            trigger: 'manual'
            html: true
            animate: true
            placement: 'top'
            template: '<div class="popover opinions-popover"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>'
            content: ->
              data
          $("abbr.timeago").timeago()
          $this.popover('show')
          $this.data 'popover-status', 'opened'
    else
      $this.popover('hide')
      $this.data 'popover-status', 'closed'

window.open_player = (url) ->
  nw = window.open url, 'player', 'height=235,width=580,status=0,menubar=0,location=0,toolbar=0,scrollbars=0'
  if window.focus
    nw.focus()
  return false
