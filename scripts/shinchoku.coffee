module.exports = (robot) ->
  robot.hear /進捗どうですか/i, (msg) ->
    msg.send "逆に、進捗どうなったと思いますか？"
