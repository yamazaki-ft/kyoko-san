module.exports = (robot) ->
  robot.respond /bus from (shinagawa|gotenyama)/, (msg) ->
    from_place = msg.match[1]
    request = msg.http("https://floating-taiga-6784.herokuapp.com/bus/#{from_place}")
                 .get()
    request (err, res, body) ->
      json = JSON.parse body
      msg.send json.response

  robot.respond /busall from (shinagawa|gotenyama)/, (msg) ->
    from_place = msg.match[1]
    request = msg.http("https://floating-taiga-6784.herokuapp.com/busall/#{from_place}")
                 .get()
    request (err, res, body) ->
      json = JSON.parse body
      obj = json.response
      msg.send ""
      for k of obj
        msg.send "#{k}: #{obj[k]}"
