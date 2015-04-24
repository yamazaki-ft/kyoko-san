module.exports = (robot) ->
  robot.respond /好き/i, (res) ->
    res.send "は？"

  robot.respond /付き合って/i, (res) ->
    res.send "は？"
