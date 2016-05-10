# Description
#  資源の使用・予約を管理する
# 
# Dependencies:
#  None
#
# Commands:
#  hubot library list - 資源の一覧を確認する
#  hubot library status <資源> - <資源>の使用・予約状況を確認する
#  hubot library add <資源> <説明> - <資源>を登録する
#  hubot library remove <資源> - <資源>を削除する
#  hubot library use <資源> - <資源>を使用する
#  hubot library return <資源> - <資源>を返却する
#  hubot library returnf <資源> - <資源>を強制的に返却する
#  hubot library reserve <資源> - <資源>を予約する
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

# 資源テーブル
class ResourceTable extends Table
  constructor: (brain) ->
    super(brain, "resource")

  find: (name) ->
    this._findByKey(name)

  save: (resource) ->
    this._save(resource.name, resource)

  del: (resource) ->
    this._del(resource.name, resource)

# 貸出テーブル
class RentalTable extends Table
  constructor: (brain) ->
    super(brain, "rental")

  find: (resource) ->
    this._findByKey(resource.name)

  save: (rental) ->
    this._save(rental.resource.name, rental)

  del: (rental) ->
    this._del(rental.resource.name, rental)

# 予約テーブル
class ReserveTable extends Table
  constructor: (brain) ->
    super(brain, "reserve")

  find: (resource) ->
    this._findByKey(resource.name)

  save: (reserve) ->
    this._save(reserve.resource.name, reserve)

  del: (reserve) ->
    this._del(reserve.resource.name, reserve)

class Facade
  constructor: (@user, brain) ->
    @resourceTable = new ResourceTable(brain)
    @rentalTable = new RentalTable(brain)
    @reserveTable = new ReserveTable(brain)

  add: (name, caption) ->
    resource = @resourceTable.find(name)
    if resource
      return "#{name}はすでに存在します。"
    @resourceTable.save({"name": name, "caption": caption})
    return "受け付けました。"

  remove: (name) ->
    resource = @resourceTable.find(name)
    if !resource
      return "#{name}は存在しません。"
    rental = @rentalTable.find(resource)
    if rental
      return "#{name}は使用中のため削除できません。"
    reserve = @reserveTable.find(resource)
    if reserve and reserve.users.length > 0
      return "#{name}は予約が存在するため削除できません。"
    if reserve
      @reserveTable.del(reserve)
    @resourceTable.del(resource)
    return "受け付けました。"

  use: (name) ->
    resource = @resourceTable.find(name)
    if !resource
      return "#{name}は存在しません。"
    rental = @rentalTable.find(resource)
    if rental
      # 使用中
      return "#{resource.name}は使用中です。"
    else
      # 誰も使用していない
      @rentalTable.save({"resource": resource, "user": @user})
      return "受け付けました。"

  giveBack: (name, force) ->
    resource = @resourceTable.find(name)
    if !resource
      return "#{name}は存在しません。"
    rental = @rentalTable.find(resource)
    if !rental
      return "誰も使用していません。"
    if rental.user.name is @user.name or force
      # 使用者本人または強制
      @rentalTable.del(rental)
      reserve = @reserveTable.find(rental.resource)
      if reserve and reserve.users.length > 0
        # 先頭の予約者を使用者に更新する
        next = reserve.users.shift()
        @reserveTable.save(reserve)
        rental.user = next
        @rentalTable.save(rental)
        return "受け付けました。#{resource.name}の使用者は#{this._toMention(next)}になりました。"
      else
        return "受け付けました。#{resource.name}の使用者はいません。"
    else
      # 他人が使用中
      return "#{resource.name}は使用中です。"

  reserve: (name) ->
    resource = @resourceTable.find(name)
    if !resource
      return "#{name}は存在しません。"
    reserve = @reserveTable.find(resource)
    if reserve
      # 追加
      reserve.users.push(@user)
      @reserveTable.save(reserve)
    else
      # 新規作成
      @reserveTable.save({"resource": resource, "users": [@user]})
    return "受け付けました。"
  
  _status: (resource) ->
    msg = ""
    # 太字表示
    msg += "*#{resource.name}*  #{resource.caption}\n"
    rental = @rentalTable.find(resource)
    # 引用表示
    if rental
      msg += ">使用： #{this._toEmoji(rental.user)}\n"
    else
      msg += ">使用： none\n"
    reserve = @reserveTable.find(resource)
    if reserve and reserve.users.length > 0
      s = ""
      for user in reserve.users
        s += " #{this._toEmoji(user)}"
      msg += ">予約：#{s}"
    else
      msg += ">予約： none"
    return msg

  status: (name) ->
    resource = @resourceTable.find(name)
    if !resource
      return "#{name}は存在しません。"
    return this._status(resource)

  statusAll: () ->
    list = @resourceTable.findAll()
    if list.length < 1
      return "1つも存在しません。"
    msg = ""
    for resource in list
      msg += "#{this._status(resource)}\n"
    return msg

  # 通知が飛ばないように両端にアンダースコアを入れたemoji名で回避
  _toEmoji: (user) ->
    ":_#{user.name}_:"

  _toMention: (user) ->
    "@#{user.name}"

module.exports = (robot) ->

  # 資源を登録する
  robot.respond /library add (.*) (.*)/i, (res) ->
    name = res.match[1]
    caption = res.match[2]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.add(name, caption)
    res.send msg

  # 資源を削除する
  robot.respond /library remove (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.remove(name)
    res.send msg

  # 資源を使用する
  robot.respond /library use (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.use(name)
    res.send msg

  # 資源を返却する
  robot.respond /library return (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.giveBack(name, false)
    res.send msg

  # 資源を強制的に返却する
  robot.respond /library returnf (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.giveBack(name, true)
    res.send msg

  # 資源を予約する
  robot.respond /library reserve (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.reserve(name)
    res.send msg

  # 資源の一覧を確認する
  robot.respond /library list/i, (res) ->
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.statusAll()
    res.send msg

  # 資源の使用・予約状況を確認する
  robot.respond /library status (.*)/i, (res) ->
    name = res.match[1]
    facade = new Facade(res.message.user, robot.brain)
    msg = facade.status(name)
    res.send msg
