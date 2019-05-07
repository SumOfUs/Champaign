xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title "SumOfUs"
    xml.description "From Batman to Superman"
    xml.link pages_url

     @pages.each do |article|
       xml.item do
         xml.title article.title
         xml.description raw article.content
         xml.pubDate article.updated_at.to_s(:rfc822)
         xml.link member_facing_page_url(article)
         xml.guid page_url(article)
       end
     end
  end
end
