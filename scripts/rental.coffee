# Description
#  資源の使用・予約を管理する
# 
# Dependencies:
#  None
#
# Commands:
#  hubot lib list - 資源の一覧を確認する
#  hubot lib status <資源> - <資源>の使用・予約状況を確認する
#  hubot lib add <資源> <説明> - <資源>を登録する
#  hubot lib remove <資源> - <資源>を削除する
#  hubot lib use <資源> - <資源>を使用する
#  hubot lib return <資源> - <資源>を返却する
#  hubot lib returnf <資源> - <資源>を強制的に返却する
#  hubot lib reserve <資源> - <資源>を予約する
#
# Notes:
#
# Author:
#  yamazaki-ft
class Table
  constructor: (@brain, @table) ->

  findAll: ()->
    str = @brain.get(@table)
    if !str
      return []
    data = JSON.parse(str)
    # 配列に変換
    obj for name, obj of data

  _findByKey: (key) ->
    str = @brain.get(@table)
    if !str
      return null
    data = JSON.parse(str)
    data[key]

  _save: (key, obj) ->
    str = @brain.get(@table)
    if !str
      data = {}
    else
      data = JSON.parse(str)
    data[key] = obj
    @brain.set(@table, JSON.stringify(data))

  _del: (key) ->
    str = @brain.get(@table)
    if !str
      return
    data = JSON.parse(str)
    delete data[key]
    @brain.set(@table, JSON.stringify(data))

# 環境テーブル
class EnvTable extends Table
  constructor: (brain) ->
    super(brain, "env")

  find: (name) ->
    this._findByKey(name)

  save: (env) ->
    this._save(env.name, env)

  del: (env) ->
    this._del(env.name, env)

# 貸出テーブル
class RentalTable extends Table
  constructor: (brain) ->
    super(brain, "rental")

  find: (env) ->
    this._findByKey(env.name)

  save: (rental) ->
    this._save(rental.env.name, rental)

  del: (rental) ->
    this._del(rental.env.name, rental)

# 予約テーブル
class ReserveTable extends Table
  constructor: (brain) ->
    super(brain, "reserve")

  find: (env) ->
    this._findByKey(env.name)

  save: (reserve) ->
    this._save(reserve.env.name, reserve)

  del: (reserve) ->
    this._del(reserve.env.name, reserve)

class Facade
  constructor: (@user, brain) ->
    @envTable = new EnvTable(brain)
    @rentalTable = new RentalTable(brain)
    @reserveTable = new ReserveTable(brain)

  add: (name, caption) ->
    env = @envTable.find(name)
    if env
      return "#{name}はすでに存在します。"
    @envTable.save({"name": name, "caption": caption})
    return "受け付けました。"

  remove: (name) ->
    env = @envTable.find(name)
    if !env
      return "#{name}は存在しません。"
    rental = @rentalTable.find(env)
    if rental
      return "#{name}は使用中のため削除できません。"
    reserve = @reserveTable.find(env)
    if reserve and reserve.users.length > 0
      return "#{name}は予約が存在するため削除できません。"
    if reserve
      @reserveTable.del(reserve)
    @envTable.del(env)
    return "受け付けました。"

  use: (name) ->
    env = @envTable.find(name)
    if !env
      return "#{name}は存在しません。"
    rental = @rentalTable.find(env)
    if rental
      # 使用中
      return "#{env.name}は使用中です。"
    else
      # 誰も使用していない
      @rentalTable.save({"env": env, "user": @user})
      return "受け付けました。"

  giveBack: (name, force) ->
    env = @envTable.find(name)
    if !env
      return "#{name}は存在しません。"
    rental = @rentalTable.find(env)
    if !rental
      return "誰も使用していません。"
    if rental.user.name is @user.name or force
      # 使用者本人または強制
      @rentalTable.del(rental)
      reserve = @reserveTable.find(rental.env)
      if reserve and reserve.users.length > 0
        # 先頭の予約者を使用者に更新する
        next = reserve.users.shift()
        @reserveTable.save(reserve)
        rental.user = next
        @rentalTable.save(rental)
        return "受け付けました。#{env.name}の使用者は#{this._toMention(next)}になりました。"
      else
        return "受け付けました。#{env.name}の使用者はいません。"
    else
      # 他人が使用中
      return "#{env.name}は使用中です。"

  reserve: (name) ->
    env = @envTable.find(name)
    if !env
      return "#{name}は存在しません。"
    reserve = @reserveTable.find(env)
    if reserve
      # 追加
      reserve.users.push(@user)
      @reserveTable.save(reserve)
    else
      # 新規作成
      @reserveTable.save({"env": env, "users": [@user]})
    return "受け付けました。"
  
  _status: (env) ->
    msg = ""
    # 太字表示
    msg += "*#{env.name}*  #{env.caption}\n"
    rental = @rentalTable.find(env)
    # 引用表示
    if rental
      msg += ">使用： #{this._toEmoji(rental.user)}\n"
    else
      msg += ">使用： none\n"
    reserve = @reserveTable.find(env)
    if reserve and reserve.users.length > 0
      s = ""
      for user in reserve.users
        s += " #{this._toEmoji(user)}"
      msg += ">予約：#{s}"
    else
      msg += ">予約： none"
    return msg

  status: (name) ->
    env = @envTable.find(name)
    if !env
      return "#{name}は存在しません。"
    return this._status(env)

  statusAll: () ->
    list = @envTable.findAll()
    if list.length < 1
      return "1つも存在しません。"
    msg = ""
    for env in list
      msg += "#{this._status(env)}\n"
    return msg

  # 通知が飛ばないように両端にアンダースコアを入れたemoji名で回避
  _toEmoji: (user) ->
    ":_#{user.name}_:"

  _toMention: (user) ->
    "@#{user.name}"

module.exports = (robot) ->

  # 資源を登録する
  robot.respond /lib add (.*) (.*)/i, (res) ->
    name = res.match[1]
    caption = res.match[2]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.add(name, caption)
    res.send msg

  # 資源を削除する
  robot.respond /lib remove (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.remove(name)
    res.send msg

  # 資源を使用する
  robot.respond /lib use (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.use(name)
    res.send msg

  # 資源を返却する
  robot.respond /lib return (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.giveBack(name, false)
    res.send msg

  # 資源を強制的に返却する
  robot.respond /lib returnf (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.giveBack(name, true)
    res.send msg

  # 資源を予約する
  robot.respond /lib reserve (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.reserve(name)
    res.send msg

  # 資源の一覧を確認する
  robot.respond /lib list/i, (res) ->
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.statusAll()
    res.send msg

  # 資源の使用・予約状況を確認する
  robot.respond /lib status (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.status(name)
    res.send msg
