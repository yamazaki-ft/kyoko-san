# Description
#  検証環境の貸出・予約を管理する
# 
# Dependencies:
#  None
#
# Commands:
#  hubot stgall timetable - すべての検証環境の貸出・予約を確認する
#  hubot stg timetable <検証環境> - <検証環境>の貸出・予約を確認する
#  hubot stgall add <検証環境> <説明> - <検証環境>を登録する
#  hubot stgall remove <検証環境> - <検証環境>を削除する
#  hubot stg use <検証環境> - <検証環境>を使用する
#  hubot stg free <検証環境> - <検証環境>を解放する
#  hubot stg freef <検証環境> - <検証環境>を強制的に解放する
#  hubot stg reserve <検証環境> - <検証環境>を予約する
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
    @envTable.del(env)
    rental = @rentalTable.find(env)
    if rental
      @rentalTable.del(rental)
    reserve = @reserveTable.find(env)
    if reserve
      @reserveTable.del(reserve)
    return "受け付けました。"

  use: (name) ->
    env = @envTable.find(name)
    if !env
      return "#{name}は存在しません。"
    rental = @rentalTable.find(env)
    if rental
      if rental.user.name is @user.name
        # 本人が使用中
        return "すでにあなたが使用しています。"
      else
        # 他人が使用中
        return "#{this._toEmoji(rental.user)}が使用しています。"
    else
      # 誰も使用していない
      @rentalTable.save({"env": env, "user": @user})
      return "受け付けました。"

  free: (name, force) ->
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
      return "#{this._toEmoji(rental.user)}が使用しています。"

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
      return "検証環境が1つも存在しません。"
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

  # 検証環境を登録する
  robot.respond /stgall add (.*) (.*)/i, (res) ->
    name = res.match[1]
    caption = res.match[2]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.add(name, caption)
    res.send msg

  # 検証環境を削除する
  robot.respond /stgall remove (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.remove(name)
    res.send msg

  # 検証環境を使用する
  robot.respond /stg use (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.use(name)
    res.send msg

  # 検証環境を解放する
  robot.respond /stg free (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.free(name, false)
    res.send msg

  # 検証環境を強制的に解放する
  robot.respond /stg freef (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.free(name, true)
    res.send msg

  # 検証環境を予約する
  robot.respond /stg reserve (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.reserve(name)
    res.send msg

  # すべての検証環境の貸出・予約を確認する
  robot.respond /stgall timetable/i, (res) ->
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.statusAll()
    res.send msg

  # 検証環境の貸出・予約を確認する
  robot.respond /stg timetable (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.status(name)
    res.send msg
