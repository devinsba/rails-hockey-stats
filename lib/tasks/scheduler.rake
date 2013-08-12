require 'nokogiri'
require 'open-uri'

desc "This task retrieves a list of todays games and drops them into the processing queue"
task :update_games => :environment do
	puts "Updating games..."
	today = Nokogiri::HTML(open('http://www.nhl.com/ice/schedulebyday.htm?date=03/09/2013'))
	today.css('table.schedTbl a.btn').each do |link|
		if link['href'].include?('recap')
			id = link['href'].match('id=([0-9]*)')[1]
			g = Game.new(id)
			g.getData
		end
	end
	puts "done."
end