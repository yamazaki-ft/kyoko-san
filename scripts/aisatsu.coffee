module.exports = (robot) ->

  robot.hear /おはよう/i, (msg) ->
    msg.send "おはようございます！今日も1日がんばりましょう！"

  robot.hear /おつかれ/i, (msg) ->
    msg.send "今日も1日おつかれさまでした！"
