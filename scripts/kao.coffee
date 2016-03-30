# Description
#   emojiの顔を出に何か言わせる
#
# Configuration:
#   None
#
# Commands:
#   hubot kao (message) - emojiの顔に何か言わせる
#
# Author:
#   yudai-ez

module.exports = (robot) ->
  robot.respond /kao\s*(.*)?/i, (msg) ->
    message = if msg.match[1] then msg.match[1].trim() else "Please set message."
    face = ":eye: :eye:\n     :nose:\n     :lips:"
    msg.send "#{face} < #{message}"
