require_relative 'key'

follower_ids = []
$client.follower_ids(@_ke_bot_).each do |id|
  follower_ids.push(id)
end
friend_ids = []
$client.friend_ids(@_ke_bot_).each do |id|
  friend_ids.push(id)
end
request_ids = []
$client.friendships_outgoing.each do |id|
  request_ids.push(id)
end

fol = follower_ids - friend_ids - request_ids
$client.follow(fol) if fol.empty? == false
