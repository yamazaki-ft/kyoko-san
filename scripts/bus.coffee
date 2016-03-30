# Description
#   御殿山トラストシティのバスの時間を返す
#
# Configuration:
#   None
#
# Commands:
#   hubot bus from gotenyama - 御殿山からの次のバスの時間を表示する
#   hubot bus from shinagawa - 品川駅からの次のバスの時間を表示する
#   hubot busall from gotenyama - 御殿山からのバスの時刻表を表示する
#   hubot busall from shinagawa - 品川駅からのバスの時刻表を表示する
#
# Author:
#   yudai-ez

module.exports = (robot) ->
  robot.respond /bus from (shinagawa|gotenyama)/, (msg) ->
    request = msg.http("https://floating-taiga-6784.herokuapp.com/bus/#{msg.match[1]}").get()

    request (err, res, body) ->
      result = JSON.parse body
      msg.send result.response

  robot.respond /busall from (shinagawa|gotenyama)/, (msg) ->
    request = msg.http("https://floating-taiga-6784.herokuapp.com/busall/#{msg.match[1]}").get()

    request (err, res, body) ->
      result    = JSON.parse body
      timetable = result.response
      message   = ""

      for k of timetable
        message += "#{k}: #{timetable[k]}" + '\n'

      msg.send message
