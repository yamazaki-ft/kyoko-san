module.exports = (robot) ->
  robot.respond /kao\s*(.*)?/i, (msg) ->
    message = if msg.match[1] then msg.match[1].trim() else "Please set message."
    face = ":eye: :eye:\n     :nose:\n     :lips:"
    msg.send "#{face} < #{message}"
