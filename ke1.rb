require 'twitter'
require 'tweetstream'
require 'pp'
require 'uri'
require_relative 'key'
require_relative 'numeron'
require_relative 'poker'

streamclient = TweetStream::Client.new

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

ke.each do |name,count|
  puts "#{name} #{count}"
end

#$client.update("稼働を開始しました#{Time.now}")

begin
  streamclient.userstream do |status|
    #TL取得
    username = status.user.screen_name
    contents = status.text
    id = status.id
    str = username + ":" + contents
    puts str
    
    if contents =~ /毛ポイント/
      $client.update("@#{username}さんの毛ポイントは #{ke[username]}毛 です。",:in_reply_to_status_id => id)
      
    elsif contents =~ /毛ランキング|毛ランク/
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
       
    elsif contents =~ /毛/ && id != "_ke_bot_"
      begin
        ke[username]+=1
        $client.update("@#{username} 毛",:in_reply_to_status_id => id)
      rescue
        puts "muri"
        $client.update("@#{username} #{er.message}")
      else
        puts "success"
      end
      file = open("count.dat","w")
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
   
    #ヌメロン判定
    if contents =~ /@_ke_bot_.*\d{4}|@_ke_bot_.*\h{6}/
      puts "数字を検出"
      ke[username] += Numeron.judge(status)
    end
   
    #ヌメロン開始
    if contents =~ /ヌメロン.*16/
      Numeron.generate(status,6)
    elsif contents =~ /@_ke_bot_.*あそぼ|ヌメロン/
      Numeron.generate(status,4)
    end
    
    #ポーカー
    if contents =~ /ポーカー.*\d+/
      puts "ポーカー開始"
      Poker.deal(status)
    end
    if contents =~ /@_ke_bot_.*[0-1]{5}/
      Poker.change(status)
      Poker.judge(status)
    end
  end
  rescue Interrupt, StandardError
  #$client.update ("稼働を停止しました#{Time.now}")
end
