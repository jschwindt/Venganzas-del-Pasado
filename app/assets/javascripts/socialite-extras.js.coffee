Socialite.widget 'facebook', 'likebox',
  init: (instance) ->
    el = document.createElement 'div'
    el.className = 'fb-like-box'
    Socialite.copyDataAttributes instance.el, el
    instance.el.appendChild el
    if window.FB && window.FB.XFBML
      window.FB.XFBML.parse instance.el
      
Socialite.widget 'twitter', 'timeline',
  init: (instance) ->
    el = document.createElement 'a'
    el.className = 'twitter-timeline'
    Socialite.copyDataAttributes instance.el, el
    instance.el.appendChild el
  activate: (instance) ->
    if (window.twttr && typeof window.twttr.widgets is 'object' && typeof window.twttr.widgets.load is 'function')
      window.twttr.widgets.load()