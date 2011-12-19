jQuery ->

  $.jPlayer.timeFormat.showHour = true

  $(".jp-audio").each ->
    container_id = $(this).attr("id")
    url = $(this).attr("data-url")
    jplayer_id = $(this).find(".jp-jplayer").attr("id")

    $("##{jplayer_id}").jPlayer
      ready: ->
        $(this).jPlayer "setMedia",
          mp3: url
      play: ->
        $(this).jPlayer "pauseOthers"
      cssSelectorAncestor: "##{container_id}"
      swfPath: "/assets"
      supplied: "mp3"
      preload: "none"
