//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require bootstrap-notify
//= require jquery.timeago
//= require jquery.timeago-es
//= require socialite
//= require socialite-extras
//= require detect-mobile
//= require jquery.appear
//= require jquery.markdownify
//= require_self

jQuery ->
  $("abbr.timeago").timeago()

  $('#markdownify').markdownify()

  $('.open_player').click (event) ->
    open_player this.href
    return false

  Socialite.setup
    facebook:
      lang     : 'es_LA',
      appId    : '305139166173322'

  if not isMobile()
    $facebookLikebox = $('.facebook-likebox')[0]
    $twitterTimeline = $('.twitter-timeline')[0]

    if $facebookLikebox
      Socialite.load $facebookLikebox
      Socialite.activate $facebookLikebox

    if $twitterTimeline
      Socialite.load $twitterTimeline
      Socialite.activate $twitterTimeline

  $('.post .share').appear
    interval: 2000

  $(document.body).on 'appear', '.post .share', (event) ->
    Socialite.load this

  $('#new_comment').on 'ajax:success', (event) ->
    this.reset()

  $('a[href^="#play-"]').on 'click', (event) ->
    event.preventDefault()
    link = $(this).attr('href')
    time = link.replace('#play-', '')
    min_sec = time.split(':')
    if min_sec.length == 2
      mins = parseInt(min_sec[0], 10)
      secs = parseInt(min_sec[1], 10)
      player = $(this).parents('article.post').first().find('audio')[0]
      if player && mins >= 0 && mins < 120 && secs >=0 && secs < 60
        player.currentTime = mins * 60 + secs
        player.play()

  $(document).on 'click', '.btn-opinions-popover', (event) ->
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
  nw = window.open url, 'player', 'height=200,width=600,status=0,menubar=0,location=0,toolbar=0,scrollbars=0'
  if window.focus
    nw.focus()
  return false

window.softScrollTo = (element) ->
  $('html, body').animate
    scrollTop: $(element).offset().top - $('#topbar').height() - 20
    'slow'

window.notify = (message, type = 'success') ->
  $notifications = $('.notifications')

  if $notifications.length is 0
    $notifications = $(document.createElement 'div')
    $notifications.addClass('notifications bottom-right')
    $('body').append($notifications)

  $notifications.notify
      message:
        text: message
      type: type
      fadeOut:
        enabled: true
        delay: 5000
    .show()
