module.exports = (robot) ->
  robot.respond /(掃除|souji|そうじ)/, (msg) ->
    members = [
      "@yudai",
      "@saigusa",
      "@uru",
      "@kayku",
      "@tanaka",
      "@hisamatsukouji",
      "@ooe"
    ]
    member = msg.random members
    msg.send "今日の掃除当番は#{member}さんです！！！"
