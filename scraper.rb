require 'mechanize'
require 'scraperwiki'

class GroupFinder
  # @agent = Mechanize.new

  def initialize
    @agent = Mechanize.new
  end

  def freecycle_links
    page = @agent.get('https://www.freecycle.org/browse/UK')
    page.links_with(css: "#active_regions a", href: /www.freecycle/).each do |link|
      region_page = link.click
      group_links = region_page.links.find_all { |l| l.href.include?("groups.freecycle") }
      save_links({ network: "freecycle", region_link: link, group_links: group_links })
    end
  end

  def freegle_links
    page = @agent.get('https://ilovefreegle.org/groups')
    page.links_with(css: "#regions a", href: /groups/).each do |link|
      region_page = link.click
      group_links = region_page.links.find_all { |l| l.href.include?("directv2.ilovefreegle.org") }
      save_links({ network: "freegle", region_link: link, group_links: group_links })
    end
  end

  def save_links(opts)
    opts[:group_links].each do |link|
      row = { country: "UK" }
      row[:name] = link.to_s
      row[:href] = link.href
      row[:region] = opts[:region_link].to_s
      row[:network] = opts[:network]
      ScraperWiki.save_sqlite([:name], row)
    end
  end
end


finder = GroupFinder.new
finder.freecycle_links
finder.freegle_links
