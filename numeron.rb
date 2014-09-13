module Numeron
  def initialize()
    @@data = Hash.new
    @@data.default = 0
  end

  def generate(status) #4桁の被らない数字を生成
    username = status.user.screen_name
    num = ""
    4.times do
      i = rand(0..9).to_s
      repeat = 0
      num.each_char do |c|
        repeat = 1 if c == i
      end
      redo if repeat == 1
      num += i
    end
    puts num
    @@data[username] = Hash.new
    @@data[username]["answer"] = num
    @@data[username]["count"] = 0
    @@data[username]["time"] = Time.now.to_i
    puts @@data
    $client.update("@#{username} 開始しました",:in_reply_to_status_id => status.id)
  end

  def judge(status)
    reply = status.text.gsub(/[^0-9]/,"")
    username = status.user.screen_name
    puts "judge呼び出し #{@@data[username]}"
    if @@data[username] == 0 
      puts "強制終了"
      return 0
    end
    eat = 0
    bite = 0
    i = 0
    @@data[username]["count"] += 1
    reply.each_char do |c1|
      j = 0
      @@data[username]["answer"].each_char do |c2|
        if c1 == c2
          eat += 1  if i == j
          bite += 1 if i != j
          break
        end
        j+=1
      end
      i+=1
    end
    $client.update("@#{username} #{@@data[username]["count"]}回目:#{eat}EAT-#{bite}BITE",:in_reply_to_status_id => status.id)
    if eat == 4
      puts "seikai"
      ret = @@data[username]["count"]
      time = Time.now.to_i - @@data[username]["time"]
      puts time
      @@data[username] = 0
      if ret < 25
        score = 30 - ret
      else
        score = 5
      end
      $client.update("@#{username} #{ret}回で正解しました！(経過時間:#{time}秒) ポイントを #{score}毛 獲得しました！",:in_reply_to_status_id => status.id)
      return ret
    end
    return 0
  end

  module_function :initialize
  module_function :generate
  module_function :judge
end

Numeron.initialize
