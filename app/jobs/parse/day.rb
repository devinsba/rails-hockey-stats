require 'nokogiri'
require 'open-uri'

class Parse::Day
  def initialize(date)
    @date = date.strftime('%m/%d/%Y')
    @games = Array.new
  end

  def parse
    today = Nokogiri::HTML(open('http://www.nhl.com/ice/schedulebyday.htm?date=%s' % @date))
    today.css('table.schedTbl a.btn').each do |link|
      if link['href'].include?('recap')
        id = link['href'].match('id=([0-9]*)')[1]
        @games.push(id)
      end
    end
    return @games
  end
end