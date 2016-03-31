# Description
#   ランチおみくじ
#
# Configuration:
#   None
#
# Commands:
#   hubot lunch - ランチおみくじ
#   hubot らんち - ランチおみくじ
#   hubot ランチ - ランチおみくじ
#
# Author:
#   curious-core

module.exports = (robot) ->
  robot.respond /(ランチ|らんち|lunch)/, (msg) ->
    restaurants = [
      ["カツ丼が美味しい蕎麦屋", "http://tabelog.com/tokyo/A1314/A131403/13001633/"],
      ["普通盛りが500gの蕎麦屋", "http://tabelog.com/tokyo/A1314/A131405/13187903/"],
      ["牛タンシチュー", "http://tabelog.com/tokyo/A1314/A131405/13177432/"],
      ["ビッグハラミ", "http://tabelog.com/tokyo/A1314/A131405/13177432/"],
      ["和食とろろ食べ放題", "http://tabelog.com/tokyo/A1316/A131603/13156077/dtlmenu/lunch/"],
      ["イタリアン", "http://tabelog.com/tokyo/A1314/A131403/13013919/dtlmenu/lunch/"],
      ["焼きそば中華", "http://tabelog.com/tokyo/A1316/A131604/13049008/"],
      ["とんかつ", "http://tabelog.com/tokyo/A1316/A131604/13042773/"],
      ["パン食べ放題", "http://tabelog.com/tokyo/A1316/A131604/13116332/"],
      ["シンガポールチキンライス", "http://tabelog.com/tokyo/A1314/A131405/13143763/"],
      ["タイ料理", "http://tabelog.com/tokyo/A1314/A131403/13011021/"],
      ["九州料理", "http://tabelog.com/tokyo/A1314/A131405/13173532/"],
      ["ネパール料理", "http://tabelog.com/tokyo/A1314/A131405/13113101/"],
    ]
    restaurant = msg.random restaurants
    msg.send "今日のお昼は#{restaurant[0]}なんてどうですか？ #{restaurant[1]}"
