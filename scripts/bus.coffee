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
