class Trump
  def initialize(suite,num)
    @suite = suite
    @num = num
  end
  
  def output
    case @num
    when 14
      num = "A"
    when 11
      num = "J"
    when 12
      num = "Q"
    when 13
      num = "K"
    else
      num = @num
    end
    return "#{@suite}#{num}"
  end
  
  attr_reader :suite
  attr_reader :num
end

module Poker
  def initial
    @@mark = Hash.new
    @@mark.default = 0
    @@data = Hash.new
    @@data.default = 0
    @@card = Array.new
    for i in ["♡","♢","♤","♧"]
      for j in 2..14  #Aは14として扱う
        @@card << Trump.new(i,j)
      end
    end
  end
  
  def deal(status,ke,mark)
    puts "le"
    username = status.user.screen_name
    bet = status.text.gsub(/\D/,"").to_i
    @@mark[username] = mark
    ke *= mark

    #前回プレイ時からの時間
    if @@data[username].is_a?(Time)
      return 0 if @@data[username] > Time.now
    end
    p "a"
    if bet < 10
      $client.update("@#{username} 10毛以上BETしてください",:in_reply_to_status_id => status.id)
      return 0
    end
    if bet > ke
      $client.update("@#{username} 毛ポイントが足りません",:in_reply_to_status_id => status.id)
      return 0
    end
    talon  = @@card.shuffle
    hand = Array.new
    5.times do
      hand << talon.pop
    end
    card = ""
    hand.each do |i|
      card+=i.output+" "
    end
   p "da"

    @@data[username] = Hash.new
    @@data[username]["hand"] = hand
    @@data[username]["talon"]= talon
    @@data[username]["bet"]  = bet  #賭けポイント
    #judge(hand)
    $client.update("@#{username} #{card}",:in_reply_to_status_id => status.id)
    return bet
  end
 
  def change(status)
    username = status.user.screen_name
    order = status.text.gsub(/[^0-1]/,"")
    i=0
    order.each_char do |c|
      if c == "1"
        @@data[username]["hand"][i] = @@data[username]["talon"].pop
      end
      i+=1
      break if i == 5
    end
    @@data[username]["result"]=""
    @@data[username]["hand"].each do |i|
      @@data[username]["result"]+=i.output+" "
    end
  end
  
  def judge(status)
    username = status.user.screen_name
    hand = @@data[username]["hand"]
    suitetime = Hash.new
    suitetime.default = 0
    numtime = Hash.new
    numtime.default = 0
    hand.each do |i|    #それぞれの数字、マークの出現回数をハッシュに代入
      suitetime[i.suite]+=1
      numtime[i.num]+=1
    end
    
    #ストレート？
    if numtime.size == 5 #数字が5種類
      numlist = Array.new
      hand.each do |i|
        numlist << i.num
      end
      if numlist.max - numlist.min == 4
        if numlist.max == 14
          straight = 2 #ロイヤルフラグ
        else
          straight = 1
        end
      elsif numlist.inject(0){|sum,i| sum+=i } == 15
        straight = 1
      end
    end
    
    #フラッシュ？
    flash = 1 if suitetime.size == 1 #マークが一種類
    puts "pair"
    #ペア系判定
    min = numtime.min { |a,b| a[1] <=> b[1] }[1] #同じ数字が出た回数の最大最小
    max = numtime.max { |a,b| a[1] <=> b[1] }[1]
    puts "#{min},#{max}"
    if max == 4
      pair = 5  #フォーカード
    elsif min == 2 and max == 3
      pair = 4  #フルハウス
    elsif max == 3
      pair = 3  #スリーカード
    elsif max == 2
      i = 0
      numtime.each do |key,value|
        i += 1 if value == 2
      end
      pair = 2 if i == 2  #ツーペア
      pair = 1 if i == 1  #ワンペア
    end
    puts "最終判定に入る" 
    #結果
    if straight == 2 and flash == 1
      win = "ロイヤルストレートフラッシュ"
      odds = 1000
    elsif straight == 1 and flash == 1
      win = "ストレートフラッシュ"
      odds = 100
    elsif straight == 1 or straight == 2
      win = "ストレート"
      odds = 8
    elsif flash == 1
      win = "フラッシュ"
      odds = 10
    elsif pair == 5
      win = "フォーカード"
      odds = 50
    elsif pair == 4
      win = "フルハウス"
      odds = 15
    elsif pair == 3
      win = "スリーカード"
      odds = 3
    elsif pair == 2
      win = "ツーペア"
      odds = 2
    elsif pair == 1
      win = "ワンペア"
      odds = 1
    else
      win = "ブタ"
      odds = 0
    end
    puts "判定おわり"
    point = @@data[username]["bet"]*odds*@@mark[username]
    limit = Time.now + POKER_LIMIT
    $client.update("@#{username} #{@@data[username]["result"]}\n結果：#{win}\n#{(@@mark[username]*@@data[username]["bet"]).jpy_comma}×#{odds}= #{point.jpy_comma}毛 獲得しました！\n次回は#{limit.to_s[11..18]}よりプレイ可能",:in_reply_to_status_id => status.id)
    @@data[username] = limit
    return point
  end
  
  module_function :initial
  module_function :change
  module_function :deal
  module_function :judge
end

Poker.initial
