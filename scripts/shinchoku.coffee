module.exports = (robot) ->
  robot.hear /進捗どうですか/i, (msg) ->
    messages = [
      "逆に、進捗どうなったと思いますか？",
      "進捗ゼロでございます",
      "進捗は常に最高であり最悪である",
      "http://i.imgur.com/LIsM5QI.jpg"
    ]
    msg.send msg.random(messages)
