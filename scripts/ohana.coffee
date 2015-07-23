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
    str = if msg.match[1] then msg.match[1].trim()+"！" else "突然の死！"
    len = Math.floor(str.lengthByte() / 2)

    msg.send ":hibiscus:" + (":hibiscus:".repeat(len)) + ":hibiscus:"
    msg.send ":hibiscus: " + str + " :hibiscus:"
    msg.send ":hibiscus:" + (":hibiscus:".repeat(len)) + ":hibiscus:"
