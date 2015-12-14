module.exports = (robot) ->
  robot.respond /おはよう/i, (msg) ->
    msg.send "おはようございます！今日も1日がんばりましょう！"

  robot.respond /おつかれ/i, (msg) ->
    msg.send "今日も1日おつかれさまでした！"
