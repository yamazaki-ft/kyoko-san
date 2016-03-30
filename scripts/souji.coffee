# Description
#   掃除当番おみくじ
#
# Configuration:
#   None
#
# Commands:
#   hubot souji - 掃除当番おみくじ
#
# Author:
#   yudai-ez

module.exports = (robot) ->
  robot.respond /(掃除|souji|そうじ)/, (msg) ->
    members = [
      "@yudai",
      "@saigusa",
      "@uru",
      "@kyaku",
      "@tanaka",
      "@hisamatsukouji",
      "@ooe"
    ]
    member = msg.random members
    msg.send "今日の掃除当番は #{member} さんです！！！"
