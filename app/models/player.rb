require 'nokogiri'
require 'open-uri'

class Player < ActiveRecord::Base

  PLAYER_PAGE = 'http://www.nhl.com/ice/player.htm?id=%s'

  def retrieve(nhl_id)
    page = Nokogiri::HTML(open(PLAYER_PAGE % nhl_id))
    heading = page.xpath('//*[@id="tombstone"]/div[2]/h1')[0].content.squish
    name = heading.match('([^#]*)(\\s*#[0-9]*)?$')[1].squish
    reg = name.match('(.*)\\s+(\\S*)$')
    self.last_name = reg[2]
    self.first_name = reg[1]
  end

end
