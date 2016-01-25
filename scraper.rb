require 'mechanize'
require 'scraperwiki'

agent = Mechanize.new  
page = agent.get('https://www.freecycle.org/browse/UK')

page.links_with(css: "#active_regions a", href: /www.freecycle/).each do |link|
  region_page = link.click
  group_links = region_page.links.find_all { |l| l.href.include?("groups.freecycle") }
  group_links.each do |glink|
    row = { region: link.to_s, country: "UK" }
    row[:name] = glink.to_s
    row[:href] = glink.href
    puts row
    ScraperWiki.save_sqlite([:name], row)
  end
end

