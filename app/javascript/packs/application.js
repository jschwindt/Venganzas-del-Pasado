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

    $('a[href^="#play-"]').on('click', (event) => {
        var target, audio, current_time, h_m_s, player, _i, _len, _ref;
        event.preventDefault();
        target = event.currentTarget;
        h_m_s = $(target).attr('href').replace('#play-', '').split(':');
        current_time = 0;
        if (h_m_s.length === 2) {
            current_time = parseInt(h_m_s[0]) * 60 + parseInt(h_m_s[1]);
        } else if (h_m_s.length === 3) {
            current_time = parseInt(h_m_s[0]) * 3600 + parseInt(h_m_s[1]) * 60 + parseInt(h_m_s[2]);
        } else {
            return;
        }
        player = $(target).parents('article.post').first().find('audio')[0];
        if (player && current_time > 0 && current_time < 8000) {
            _ref = $('audio');
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                audio = _ref[_i];
                audio.pause();
            }
            player.currentTime = current_time;
            player.play();
            player.oncanplay = (e) => {
                if (player.currentTime == 0) {
                    player.currentTime = current_time;
                }
            }
        }
    });

    $('a[data-toggle="collapse"]').on('click', (event) => {
        event.preventDefault();
        target = event.currentTarget;
        $(target).next('ul.archive-months').toggle();
    });

})