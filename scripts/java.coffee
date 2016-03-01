module.exports = (robot) ->
  robot.hear /あなたとジャバ/i, (res) ->
    res.send "いますぐダウンロー\nド"
