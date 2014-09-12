require 'twitter'
require 'tweetstream'
require 'pp'
require 'uri'
require_relative 'key'
require_relative 'numeron'

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

$client.update("稼働を開始しました#{Time.now}")

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
  	if contents == "sonohennniiruガチャ"
  		puts "sonohenn"
  		$client.update_with_media("@#{username} ",File.open("naja.png"),:in_reply_to_status_id => id)
  	end
  	if contents == "sonohennniiru10連ガチャ"
  		10.times do
  			$client.update_with_media("@#{username} ",File.open("naja.png"),:in_reply_to_status_id => id)
  		end
  	end
  	if contents =~ /うしうしガチャ/
  		fname = "usiusi" + rand(1..10).to_s + ".jpg"
  		puts fname
  		$client.update_with_media("@#{username} ",File.open(fname),:in_reply_to_status_id => id)
  	end
  	if contents =~ /方程式/
      eq[username][0] = rand(-10..10)
      eq[username][1] = rand(-10..10)
      a = -(eq[username][0] + eq[username][1])
      b = eq[username][0] * eq[username][1]
      sentence = "毛^2"
      sentence += "+" if a>0
      sentence += "#{a}毛"
      sentence += "-" if b>0
      sentence += "#{b}=0"
  		$client.update("@#{username} #{sentence}",:in_reply_to_status_id => id)
    end
    #数字を拾うテスト
    if contents =~ /@_ke_bot_.*\d{4}/
      puts "数字を検出"
      reply = Numeron.judge(status)
      if reply != 0
        score = 5
        score = 30 - reply if reply <= 25
        $client.update("@#{username} #{reply}回で正解しました！ ポイントを #{score}毛 獲得しました！",:in_reply_to_status_id => id)
        ke[username] += score
      end
    end
    #テストここまで
    if contents =~ /@_ke_bot_.*あそぼ|ヌメロン/
      Numeron.generate(status)
    end
  end
  rescue Interrupt, StandardError
  $client.update ("稼働を停止しました#{Time.now}")
end
