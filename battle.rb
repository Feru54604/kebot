require 'PStore'

#勝敗数のロード
db = PStore.new('battle')
db.transaction(true) do
  $win = db['win']
  $lose = db['lose']
  $straight = db['straight']
  $battleplus = db['battlesum']
  $battleminus = db['battleminus']
end

=begin
$battleplus = Hash.new
$battleplus.default = 0
$battleminus = Hash.new
$battleminus.default = 0
=end

def ke_battle(status,point)
  username = status.user.screen_name
  contents = status.text
  opponent = status.in_reply_to_screen_name
  win = 0
  judge = rand(0..1)
  if judge == 1
    #勝ち
    $win[username]+=1
    if $straight[username] < 0 #連勝カウント
      $straight[username] = 1
    else
      $straight[username] += 1
    end
    $lose[opponent]+=1
    if $straight[opponent] > 0 #連敗かうんと
      $straight[opponent] = -1
    else
      $straight[opponent] -= 1
    end
    p = rand(1..100)
    $client.update("@#{username}さんは@#{opponent}さんに勝利し#{p}毛獲得しました！現在#{$win[username]}勝#{$lose[username]}敗#{$straight[username]}連勝中",:in_reply_to_status_id => status.id)
=begin
    if $straight[username] % 3 == 0
      win = point * ($straight[username]/3)
      $client.update("@#{username} 連勝ボーナスで#{win}毛獲得しました！",:in_reply_to_status_id => status.id)
    end
=end
  else
    #負け
    $lose[username]+=1
    if $straight[username] > 0
      $straight[username] = -1
    else
      $straight[username] -= 1
    end
    $win[opponent]+=1
    if $straight[opponent] < 0
      $straight[opponent] = 1
    else
      $straight[opponent] += 1
    end
    p = -rand(1..100)
    $client.update("@#{username}さんは@#{opponent}さんに敗北し#{-p}毛失いました。現在#{$win[username]}勝#{$lose[username]}敗#{-$straight[username]}連敗中",:in_reply_to_status_id => status.id)
=begin
    if $straight[username] % 3 == 0
      win = point*9/10 * ($straight[username]/3)
      $client.update("@#{username} 連敗ボーナスで#{-win}毛失いました",:in_reply_to_status_id => status.id)
    end
=end
  end
  #セーブ
  $battleplus[username] += p if p>0
  $battleminus[username] += p if p<0
  $battleplus[username] += win if win>0
  $battleminus[username] -= win if win<0
  db = PStore.new('battle')
  db.transaction do
    db['win'] = $win
    db['lose'] = $lose
    db['straight'] = $straight
    db['battlesum'] = $battleplus
    db['battleminus'] = $battleminus
  end

  return p+win
end

=begin
$win = Hash.new
$win.default = 0
$lose = Hash.new
$lose.default = 0
$straight = Hash.new
$straight.default = 0
$battleplus = Hash.new
$battleplus.default = 0
$battleminus = Hash.new
$battleminus.default = 0
=end
