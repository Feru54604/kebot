def feru(status)
  username = status.user.screen_name
  puts "yobidasi"
  file = open("feru/list2.dat","r")
  list = Array.new
  while line = file.gets
    list << line
  end
  puts "aaa" 
  icon = list.sample.split(" ")
  str = ""
  puts "icon?"
  str += "No."+icon[0] + "\n"
  puts "casemae"
  case icon[1]
  when "N" then
    str += "N "
  when "R" then
    str += "[R]"
  when "SR" then
    str += "【SR】"
  when "UR" then
    str += "＜＜UR＞＞"
  end
  puts "casego"
  str += icon[2]
  puts "tasi"
  fname = "feru/" + icon[0] + ".png"
  puts str
  puts fname
  $client.update_with_media("@#{username} #{str}",File.open(fname),:in_reply_to_status_id => status.id)
  
  file.close
end
