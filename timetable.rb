require 'PStore'

module Timetable
  def initial
    @@table = Hash.new
    @@table.default = 0
    #table[username][0~4の曜日を表す数][1~5の時限を表す数]
    @@day = ["月","火","水","木","金"]
  end
  
  def load
    @@day = ["月","火","水","木","金"]
    db = PStore.new('timetable')
    db.transaction(true) do
      @@table = db['timetable']
    end
  end
  
  def save
    db = PStore.new('timetable')
    db.transaction do
      db['timetable'] = @@table
    end
  end
  
  module_function :save
  
  def add(status)
    username = status.user.screen_name
    contents = status.text
    #timedata[0]に曜 [1]に時限 [2]に授業名 [3]に教室
    ts = contents.gsub(/@_ke_bot_/," ")
    tas = ts.gsub!(/曜|限/," ")
    timedata = tas.split
    day = @@day.index(timedata[0])
    if day == nil
      #不正な曜日
    end
    if @@table[username] == 0
      @@table[username] = Array.new
      for i in 0..4 do
        @@table[username][i] = Array.new
        for j in 1..5 do
          @@table[username][i][j] = ["空きコマ",""]
        end
      end
    end
    @@table[username][day][timedata[1].to_i]=[timedata[2] , timedata[3]]
    self.save
    self.viewall(username)
    $client.update("@#{username} #{timedata[0]}曜#{timedata[1]}限に#{timedata[2]}を登録しました",:in_reply_to_status_id => status.id)
  end
  
  def viewall(username)
    for i in 0..4 do
      puts "#{@@day[i]}曜日"
      for j in 1..5 do
        puts "#{@@table[username][i][j][0]}\t#{@@table[username][i][j][1]}"
      end
    end
  end
 
  def viewday(status)
    username = status.user.screen_name
    contents = status.text
    #contents = status
    #username = "Feru"
    contents = contents.scan(/月|火|水|木|金/)[0]
    day = @@day.index(contents)
    if day == nil
      #不正な曜日
      return
    end
    text = "@#{username} #{contents}曜日\n"
    for i in 1..5
      text += "#{i} #{@@table[username][day][i][0]} #{@@table[username][day][i][1]}\n"
    end
    $client.update("#{text}",:in_reply_to_status_id => status.id)
  end
 
  def viewtoday(status,relative)
    now = Time.now
    username = status.user.screen_name
    day = now.wday - 1 + relative
    text = "#{@@day[day]}曜日\n"
    for i in 1..5
      text += "#{i} #{@@table[username][day][i][0]} #{@@table[username][day][i][1]}\n"
    end
    puts text
    $client.update("@#{username} #{text}",:in_reply_to_status_id => status.id) 
  end

  module_function :initial
  module_function :load
  module_function :add
  module_function :viewall
  module_function :viewday
  module_function :viewtoday
end

Timetable.load
