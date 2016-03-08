module.exports = (robot) ->
  robot.hear /進捗どうですか/i, (msg) ->
    messages = [
      "逆に、進捗どうなったと思いますか？",
      "進捗ゼロでございます",
      "進捗は常に最高であり最悪である",
      "http://image.slidesharecdn.com/adventcalendar-151201104600-lva1-app6892/95/advent-calendar-23-638.jpg?cb=1448966864"
    ]
    msg.send msg.random(messages)
