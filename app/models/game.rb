require 'nokogiri'
require 'open-uri'

BOXSCORE = 'http://www.nhl.com/ice/boxscore.htm?id=%s'
HOME_TOI = 'http://www.nhl.com/scores/htmlreports/%d%d/TH%s.HTM'
AWAY_TOI = 'http://www.nhl.com/scores/htmlreports/%d%d/TV%s.HTM'
EVENTS = 'http://www.nhl.com/scores/htmlreports/%d%d/PL%s.HTM'

class Game
	def initialize(id)
		@id = id
	end

	def getData
		puts 'getData'
		getPlayers
		getShifts
		getEvents
		_processData
	end
	handle_asynchronously :getData

	def getPlayers
		puts 'getPlayers'
		box = Nokogiri::HTML(open(BOXSCORE % @id))
		_processPlayers(box)
	end

	def getShifts
		puts 'getShifts'
		home = Nokogiri::HTML(open(HOME_TOI % [Integer(@id[0, 4]), Integer(@id[0, 4]) + 1, @id[4, 6]]))
		_processShifts(home)
		away = Nokogiri::HTML(open(AWAY_TOI % [Integer(@id[0, 4]), Integer(@id[0, 4]) + 1, @id[4, 6]]))
		_processShifts(away)
	end

	def getEvents
		puts 'getEvents'
		events = Nokogiri::HTML(open(EVENTS % [Integer(@id[0, 4]), Integer(@id[0, 4]) + 1, @id[4, 6]]))
		_processEvents(events)
	end

	def _processPlayers(page)
		puts '_processPlayers'
		# process the players for the game
	end

	def _processShifts(page)
		puts '_processShifts'
		# process the TOI data
	end

	def _processEvents(page)
		puts '_processEvents'
		# Process the game events
	end

	def _processData
		puts '_processData'
		# Process the data and drop it in hadoop
	end
end