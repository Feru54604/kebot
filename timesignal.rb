require_relative 'key'

now = Time.now
$client.update("#{now.hour}時の毛")
