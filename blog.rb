require_relative 'key'
require 'rss'
require 'feedjira'

bloglist = Hash.new
bloglist["Feru"] = "http://feru.hatenadiary.jp/feed"
bloglist["中井喜一"] = "http://moccai.hatenablog.com/feed"
bloglist["かすかたん"] = "http://kasumiko.hatenablog.jp/feed"
bloglist["sonoehennniiru"] = "http://sonohennniiru.hatenadiary.jp/feed"
bloglist["うしうし"] = "http://usiusiusiusi.blog.fc2.com/?xml"

bloglist.each{|name,url|
  feed = Feedjira::Feed.fetch_and_parse(url)
  ago = Time.now.to_i - feed.entries[0].published.to_i
  if ago <= 1200
    body = feed.entries[0].content.gsub(/<.+?>/,"")
    $client.update("#{name}がブログを更新しました\n#{feed.entries[0].title} #{feed.entries[0].url}\n#{body[0,29]}…")
  end
}
