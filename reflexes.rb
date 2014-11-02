require 'PStore'

module Reflexes
  def initial
    @@time = Hash.new
    @@time.default = 0
    db = PStore.new('reflexes')
    db.transaction(true) do
      @@highscore = db['highscore']
    end
    #@@highscore = Hash.new
    #@@highscore.default = 100000
  end

  def begin(status,now)
    username = status.user.screen_name
    @@time[username] = now
  end

  def reply(status,now)
    username = status.user.screen_name
    return -1 if @@time[username] == 0
    result = now - @@time[username]
    if result < @@highscore[username]
      $client.update("@#{username} #{result}秒でした！自己最高記録です！",:in_reply_to_status_id => status.id)
      @@highscore[username] = result
      db = PStore.new('reflexes')
      db.transaction do
        db['highscore'] = @@highscore
      end
    else
      $client.update("@#{username} #{result}秒でした！",:in_reply_to_status_id => status.id)
    end
    @@time[username] = 0
  end

  def print_highscore(username)
    if @@highscore[username] == 100000
      return ""
    end
    return "反射最高記録 #{@@highscore[username]}秒"
  end

  module_function :initial
  module_function :begin
  module_function :reply
  module_function :print_highscore
end

Reflexes.initial
