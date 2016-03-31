# Description
#   ランチおみくじ
#
# Configuration:
#   None
#
# Commands:
#   hubot lunch - ランチおみくじ
#
# Author:
#   curious-core

module.exports = (robot) ->
  robot.respond /(ランチ|らんち|lunch)/, (msg) ->
    restaurants = [
      ["カツ丼が美味しい蕎麦屋", "http://tabelog.com/tokyo/A1314/A131403/13001633/"],
      ["普通盛りが500gの蕎麦屋", "http://tabelog.com/tokyo/A1314/A131405/13187903/"],
      ["牛タンシチューの店", "http://tabelog.com/tokyo/A1314/A131405/13177432/"],
    ]
    restaurant = msg.random restaurants
    msg.send "今日のお昼は#{restaurant[0]}なんてどうですか？ #{restaurant[1]}"
