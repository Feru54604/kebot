require 'twitter'
require 'tweetstream'
require 'pp'
require 'uri'
require 'workers'
require_relative 'key'
require_relative 'numeron'
require_relative 'poker'
require_relative 'feru'
require_relative 'timetable'
require_relative 'battle'
require_relative 'reflexes'

NUMERON_LIMIT = 1800
POKER_LIMIT = 600

streamclient = TweetStream::Client.new
$client = $client_main

file = open("count.dat","r+")
ke = Hash.new
ke.default = 0
eq = Hash.new
eq.default = [0,0]

while line = file.gets
  linearray = line.split(" ")
  ke[linearray[0]] = linearray[1].to_i
  p line
end
file.close

pool = Workers::Pool.new
timer = Hash.new

i=0
ke.each do |name,count|
  a="#{name} #{count}"
  a+=" "*(30-a.size)
  print a
  i+=1
  puts "" if i%3==0
end
puts ""

#$client.update("稼働を開始しました#{Time.now}")

  streamclient.userstream do |status|
  retry_counter = 0
  begin
    #TL取得
    now = Time.now
    username = status.user.screen_name
    contents = status.text
    id = status.id
    str = username + ":" + contents
    puts str
    
    if contents =~ /毛ポイント/ # && username != "_ke_bot_"
      if username == "_ke_bot_" or username == "_ke_bot__" #自分には20%で反応
        next if (rand 1..100) > 20
      end
      $client.update("@#{username}さんの毛ポイントは #{ke[username]}毛 です。",:in_reply_to_status_id => id)
      
    elsif contents =~ /毛ランキング|毛ランク/ # && username != "_ke_bot_"
      if username == "_ke_bot_" or username == "_ke_bot__" #自分には50%で反応
        next if (rand 1..100) > 50
      end
      rank = ke.sort{|(k1, v1), (k2,v2)| v2 <=> v1}
      puts rank
      i = 0
      j = 0
      prev = 0
      rank.each{|key, value|
        i += 1
        if value != prev
          j = i
          prev = value
        end
      break if key == username
      }
      puts i
      $client.update("@#{username}さんは毛ランク#{j}位です。(#{ke.size}人中)",:in_reply_to_status_id => id)

    elsif contents =~ /@.*毛バトル/
      ke[username] += ke_battle(status,ke[username])

    elsif contents =~ /@.*毛データ/
      user = status.in_reply_to_screen_name
      rank = ke.sort{|(k1, v1), (k2,v2)| v2 <=> v1}
      next if username =~ /_ke_bot_/
      i = 0
      j = 0
      prev = 0
      rank.each{|key, value|
        i += 1
        if value != prev
          j = i
          prev = value
        end
      break if key == user
      }
      str = "@#{username}\n\n@#{user}の毛データ\n"
      str +="#{ke[user]}毛 #{j}位/#{ke.size}人\n"
      str +="戦歴 #{$win[user]}勝#{$lose[user]}敗 勝率#{100*$win[user]/($win[user]+$lose[user])}%\n"
      str +="バトルで獲得した毛 #{$battleplus[user]}毛\n"
      str +="バトルで失った毛 #{$battleminus[user]}毛\n"
      str +=Reflexes.print_highscore(user)
      $client.update(str,:in_reply_to_status_id => id)

    elsif contents =~ /@.*おしつ毛/
      next if ke[username] > 0
      user = status.in_reply_to_screen_name
      $client.update("@#{username} @#{user}に#{ke[username]}毛を押し付けました。",:in_reply_to_status_id => id)
      ke[user] += ke[username]
      ke[username] = 0

    elsif contents =~ /毛/ # && id != "_ke_bot_"
      if Reflexes.reply(status,now) != -1 #反射神経測定中
        next
      end
      ke[username]+=1
      if username == "_ke_bot_" or username == "_ke_bot__" #自分には75%で反応
        next if (rand 1..100) > 75
      end
      $client.update("@#{username} 毛",:in_reply_to_status_id => id) # unless username == "_ke_bot_"
      file = open("count.dat","w") #毛ポイントをファイルに書き込む
      ke.each do |name,count|
        file.puts("#{name} #{count}")
      end
      file.close
    end
   
    if contents == "起きた" or contents == "むくり" or contents == "朝" or contents == "おはよう"
      $client.update("@#{username} おはようの毛",:in_reply_to_status_id => id)
    end
   
    if contents == "きたく" or contents == "ただいま"
      $client.update("@#{username} おかえりの毛",:in_reply_to_status_id => id)
    end
   
    if contents =~ /sonohennniiruガチャ/
      puts "sonohenn"
      $client.update_with_media("@#{username} ",File.open("naja.png"),:in_reply_to_status_id => id)
    end
   
    if contents =~ /sonohennniiru10連ガチャ/
      10.times do
        $client.update_with_media("@#{username} ",File.open("naja.png"),:in_reply_to_status_id => id)
      end
    end
   
    if contents =~ /うしうしガチャ/
      fname = "usiusi" + rand(1..10).to_s + ".jpg"
      puts fname
      $client.update_with_media("@#{username} ",File.open(fname),:in_reply_to_status_id => id)
    end
    
    if contents =~ /Feruガチャ/
      if ke[username]<5
        $client.update("@#{username} 毛ポイントが足りません",:in_reply_to_status_id => id)
      else
        feru(status)
        ke[username] -= 5
      end
    end
    
    #時間割
    if contents =~ /.曜.限/
      Timetable.add(status)
    end
    if contents =~ /今日の時間割/
      Timetable.viewtoday(status,0)
    elsif contents =~ /明日の時間割/
      Timetable.viewtoday(status,1)
    elsif contents =~ /時間割/
      Timetable.viewday(status)
    end
=begin
    #ヌメロン判定
    if contents =~ /@_ke_bot_.*\d{4}|@_ke_bot_.*\h{6}/
      ke[username] += Numeron.judge(status)
    end
   
    #ヌメロン開始
    if contents =~ /ヌメロン.*16/
      Numeron.generate(status,6)
    elsif contents =~ /@_ke_bot_.*あそぼ|ヌメロン/
      Numeron.generate(status,4)
    end
=end
    #ポーカー
    if contents =~ /ポーカー.*\d+/
      puts "ポーカー開始"
      ke[username]-=Poker.deal(status,ke[username])
    elsif contents =~ /@_ke_bot_.*[0-1]{5}/
      Poker.change(status)
      ke[username]+=Poker.judge(status)
    end
    #反射神経
    if contents =~ /反射神毛/
      $client.update("@#{username} 10~20秒お待ちください.",:in_reply_to_status_id => id)
      timer[username] = Workers::Timer.new(rand(10..20)) do #並列処理で待機
        $client.update("@#{username} 毛を返してください",:in_reply_to_status_id => id)
        now = Time.now
        Reflexes.begin(status,now)
      end
    end
    pool.shutdown
    pool.join
    retry_counter = 0
  rescue Twitter::Error::Forbidden
    change_client
    retry_counter += 1
    next if retry_counter == Account_Number
    retry
  end
end
