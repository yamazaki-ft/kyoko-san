# Description
#   花に囲まれたメッセージを出す
#
# Configuration:
#   None
#
# Commands:
#   hubot ohana (message) - 花に囲まれたメッセージを出す
#
# Author:
#   yudai-ez


String::lengthByte = ->
  str = this
  r = 0
  for i in [0..str.length - 1]
    c = str.charCodeAt(i)
    if (c >= 0x0 && c < 0x81) || (c == 0xf8f0) || (c >= 0xff61 && c < 0xffa0) || (c >= 0xf8f1 && c < 0xf8f4)
      r += 1
    else
      r += 2
  return r

String::repeat = (n) ->
  return new Array(n + 1).join(this)

module.exports = (robot) ->

  robot.respond /ohana\s*(.*)?/i, (msg) ->
    str = if msg.match[1] then msg.match[1].trim()+":heart:" else "突然の死！"
    len = Math.floor(str.lengthByte() / 2)

    frame = ":hibiscus:" + (":hibiscus:".repeat(len - 2)) + ":hibiscus:"
    msg.send "#{frame}\n:hibiscus: #{str} :hibiscus:\n#{frame}"
