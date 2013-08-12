require 'nokogiri'
require 'open-uri'

BOXSCORE = 'http://www.nhl.com/ice/boxscore.htm?id=%s'
HOME_TOI = 'http://www.nhl.com/scores/htmlreports/%d%d/TH%s.HTM'
AWAY_TOI = 'http://www.nhl.com/scores/htmlreports/%d%d/TV%s.HTM'
EVENTS = 'http://www.nhl.com/scores/htmlreports/%d%d/PL%s.HTM'

EVENT_TYPE_MAP = {
	'FAC' => 'faceoff',
	'MISS' => 'miss',
	'BLOCK' => 'block',
	'SHOT' => 'shot'
}

EVENT_PARSER_MAP = {
	'FAC' => '_parseFaceoff',
	'MISS' => '_parseMiss',
	'BLOCK' => '_parseBlock',
	'SHOT' => '_parseShot'
}

class Game
	def initialize(id)
		@id = id
	end

	def getData
		puts 'getData'
		#getPlayers
		#getShifts
		getEvents
		#_processData
	end
	handle_asynchronously :getData

	def getPlayers
		puts 'getPlayers'
		@box = Nokogiri::HTML(open(BOXSCORE % @id))
		_processPlayers(@box)
	end

	def getShifts
		puts 'getShifts'
		_processGoals(@box)
		home = Nokogiri::HTML(open(HOME_TOI % [Integer(@id[0, 4]), Integer(@id[0, 4]) + 1, @id[4, 6]]))
		_processShifts(home)
		away = Nokogiri::HTML(open(AWAY_TOI % [Integer(@id[0, 4]), Integer(@id[0, 4]) + 1, @id[4, 6]]))
		_processShifts(away)
	end

	def getEvents
		puts 'getEvents'
		events = Nokogiri::HTML(open(EVENTS % [Integer(@id[0, 4]), Integer(@id[0, 4]) + 1, @id[4, 6]]))
		_processEvents(events)
		_processPenalties(@box)
	end

	def _processGoals(page)
		# Process goals from the box score
	end

	def _processPlayers(page)
		puts '_processPlayers'
	end

	def _processShifts(page)
		puts '_processShifts'
		# process the TOI data
	end

	def _processEvents(page)
		puts '_processEvents'
		headings = page.css('td.heading')
		@away = headings[6].content.match('[A-Z]{2,3}|[A-Z]\.[A-Z]')[0]
		@home = headings[7].content.match('[A-Z]{2,3}|[A-Z]\.[A-Z]')[0]
		page.css('tr.evenColor').each do |row|
			cells = row.css('td.bborder')
			type = cells[4].content
			if not EVENT_TYPE_MAP[type].nil?
				event = {
					'game' => @id,
					'period' => Integer(cells[1].content),
					'time' => __timeToInt(cells[3].content.match('^([1-2]?[0-9]:[0-5][0-9])')[0]),
					'event_type' => EVENT_TYPE_MAP[type]
				}
				m = self.method(EVENT_PARSER_MAP[type])
				m.call(event, cells[5].content)
				puts event.inspect
			end
		end
	end

	def _processPenalties(page)
		# Process penalty data
	end

	def _processData
		puts '_processData'
		# Process the data and drop it in hadoop
	end

	def _parseFaceoff(event, desc)
		winTeam = desc.match('^[A-Z]{2,3}|[A-Z]\.[A-Z]')[0]
		loseTeam = winTeam.eql?(@home) ? @away : @home
		winner = desc.match('%s #([0-9]{1,2})' % winTeam)[1]
		loser = desc.match('%s #([0-9]{1,2})' % loseTeam)[1]
		zone = desc.match('(Neu|Def|Off)\. Zone')[1][0]

		event['win_team'] = winTeam.delete('.')
		event['player'] = winner
		event['against'] = loser
		event['zone'] = zone
	end

	def _parseMiss(event, desc)
		matches = desc.match('^([A-Z]{2,3}|[A-Z]\.[A-Z]).*#([0-9]{1,2}).*(Neu|Def|Off)\. Zone')
		event['win_team'] = matches[1].eql?(@home) ? @away.delete('.') : @home.delete('.')
		event['player'] = matches[2]
		event['against'] = '' #TODO make this the current goalie for the opponent
		event['zone'] = matches[3][0]
	end

	def _parseBlock(event, desc)
		matches = desc.match('#([0-9]{1,2}).*#([0-9]{1,2})')
		loseTeam = desc.match('^[A-Z]{2,3}|[A-Z]\.[A-Z]')[0]
		winTeam = loseTeam.eql?(@home) ? @away : @home
		winner = matches[2]
		loser = matches[1]
		zone = desc.match('(Neu|Def|Off)\. Zone')[1][0]

		event['win_team'] = winTeam.delete('.')
		event['player'] = winner
		event['against'] = loser
		event['zone'] = zone
	end

	def _parseShot(event, desc)
		matches = desc.match('^([A-Z]{2,3}|[A-Z]\.[A-Z]).*#([0-9]{1,2}).*(Neu|Def|Off)\. Zone')
		event['win_team'] = matches[1].eql?(@away) ? @away.delete('.') : @home.delete('.')
		event['player'] = matches[2]
		event['against'] = '' #TODO make this the current goalie for the opponent
		event['zone'] = matches[3][0]
	end

	def __timeToInt(time)
		puts time
		matches = time.match('([0-9]*):([0-9]*)')
		min = Integer(matches[1])
		sec = Integer(matches[2].sub(/^0/, ''))
		return (min * 60) + sec
	end
end