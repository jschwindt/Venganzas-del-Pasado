// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require('@rails/ujs').start()

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

require('social-likes')
require('./bulma')
require('./timeago')

$(document).ready(() => {

    window.open_player = (url) => {
        var nw;
        nw = window.open(url, 'player', 'width=640,height=160,status=0,menubar=0,location=0,toolbar=0,scrollbars=0');
        if (window.focus) {
            nw.focus();
        }
        return false;
    };

    $('.open_player').click((event) => {
        return open_player(event.currentTarget.href);
    });

    $('a[data-toggle="collapse"]').on('click', (event) => {
        event.preventDefault();
        target = event.currentTarget;
        $(target).next('ul.archive-months').toggle();
    });

    function stop_all_players() {
        var ref = $('audio');
        for (var _i = 0, _len = ref.length; _i < _len; _i++) {
            ref[_i].pause();
        }
    }

    function seconds_from_hash(hash) {
        var h_m_s = hash.replace('#play-', '').split(':');
        var seconds = 0;
        if (h_m_s.length === 2) {
            seconds = parseInt(h_m_s[0]) * 60 + parseInt(h_m_s[1]);
        } else if (h_m_s.length === 3) {
            seconds = parseInt(h_m_s[0]) * 3600 + parseInt(h_m_s[1]) * 60 + parseInt(h_m_s[2]);
        }
        return seconds < 8000 ? seconds : 0;
    }

    function seek_and_play(href, player) {
        var current_time = seconds_from_hash(href);
        if (player && current_time > 0) {
            stop_all_players();
            player.currentTime = current_time;
            player.play();
            player.oncanplay = (e) => {
                if (player.currentTime == 0) {
                    player.currentTime = current_time;
                }
            }
        }
    }

    $(document).on('click', 'a[href^="#play-"]', (event) => {
        var target, player;
        event.preventDefault();
        target = event.currentTarget;
        player = $(target).parents('article.post').first().find('audio')[0];
        seek_and_play($(target).attr('href'), player);
    });

    if (window.location.pathname.startsWith('/posts/') && window.location.hash.startsWith('#play-')) {
        var audios = $('audio')
        var seconds = seconds_from_hash(window.location.hash);
        if (audios.length > 0 && seconds > 0) {
            $('h1.title').append('<a href="' + window.location.hash + '">' + window.location.hash.split('-')[1] + '</a>')
        }
    }
})
