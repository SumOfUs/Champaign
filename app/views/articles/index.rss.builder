xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0", "xmlns:atom": "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "SumOfUs"
    xml.description "stopping big corporations from behaving badly."
    xml.link pages_url

    @pages.each do |article|
      xml.item do
        xml.title article.title
        xml.description do
          desc = simple_format article.content
          xml.cdata! desc
        end
        xml.pubDate article.updated_at.to_s(:rfc822)
        xml.link member_facing_page_url(article)
        xml.guid member_facing_page_url(article)
      end
     end
  end
end
