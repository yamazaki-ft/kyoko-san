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
    ]
    restaurant, url = msg.random restaurants
    msg.send "今日のお昼は#{restaurant}なんてどうですか？ #{url}"
