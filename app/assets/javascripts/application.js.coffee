//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require bootstrap-notify
//= require jquery.timeago
//= require jquery.timeago-es
//= require social-likes
//= require detect-mobile
//= require jquery.appear
//= require_self

jQuery ->
  $("abbr.timeago").timeago()

  if (typeof InscrybMDE != "undefined")
    mde = new InscrybMDE(
      element: $("#markdownify")[0],
      spellChecker: false
      autofocus: true
      forceSync: true
      indentWithTabs: false
      lineWrapping: false
      blockStyles:
        bold: "**"
        italic: "_"
      insertTexts:
        link: ["[", "](#play-)"]
      toolbar: ["heading", "bold", "italic", "strikethrough", "|",
                "unordered-list", "ordered-list", "code", "quote", "link", "|",
                "preview", "side-by-side", "fullscreen", "|",
                {
                    name: 'guide'
                    action: 'https://venganzasdelpasado.com.ar/articles/como-editar-posts'
                    className: 'fa fa-info-circle',
                    noDisable: true,
                    title: 'Editor\'s Guide',
                    default: true
                },
                {
                    name: 'guide'
                    action: 'https://venganzasdelpasado.com.ar/articles/markdown'
                    className: 'fa fa-question-circle',
                    noDisable: true,
                    title: 'Markdown Guide',
                    default: true
                }
              ]
    )

    mde.codemirror.on 'refresh', ->
      if (mde.isFullscreenActive())
        $('.navbar').hide()
      else
        $('.navbar').show()

  $('.open_player').click (event) ->
    open_player this.href
    return false

  # Socialite.setup
  #   facebook:
  #     lang     : 'es_LA',
  #     appId    : '305139166173322'

  $('#new_comment').on 'ajax:success', (event) ->
    this.reset()

  $('a[href^="#play-"]').on 'click', (event) ->
    event.preventDefault()
    h_m_s = $(this).attr('href').replace('#play-', '').split(':')
    current_time = 0
    if h_m_s.length == 2
      current_time = parseInt(h_m_s[0]) * 60 + parseInt(h_m_s[1])
    else if h_m_s.length == 3
      current_time = parseInt(h_m_s[0]) * 3600 + parseInt(h_m_s[1]) * 60 + parseInt(h_m_s[2])
    else
      return
    player = $(this).parents('article.post').first().find('audio')[0]
    if player && current_time > 0 && current_time < 7200
      for audio in $('audio')
        audio.pause()
      player.currentTime = current_time
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
