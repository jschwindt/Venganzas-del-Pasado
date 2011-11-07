//= require jquery
//= require jquery_ujs
//= require bootstrap-alerts
//= require jquery.jplayer
//= require_self

$(document).ready(function() {

  $.jPlayer.timeFormat.showHour = true;

  $(".jp-audio").each(function() {
    var container_id = $(this).attr('id');
    var url = $(this).attr('data-url');
    var jplayer_id = $(this).find('.jp-jplayer').attr('id');
    $('#' + jplayer_id).jPlayer({
      ready: function () {
        $(this).jPlayer("setMedia", { mp3: url });
      },
      play: function() { // To avoid both jPlayers playing together.
        $(this).jPlayer("pauseOthers");
      },
      cssSelectorAncestor: '#' + container_id,
      swfPath: "/assets",
      supplied: "mp3"
    });
  });
});

