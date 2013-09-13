require 'nokogiri'
require 'open-uri'


BOXSCORE = 'http://www.nhl.com/ice/boxscore.htm?id=%s'
HOME_TOI = 'http://www.nhl.com/scores/htmlreports/%d%d/TH%s.HTM'
AWAY_TOI = 'http://www.nhl.com/scores/htmlreports/%d%d/TV%s.HTM'
EVENTS = 'http://www.nhl.com/scores/htmlreports/%d%d/PL%s.HTM'

EVENT_PARSER_MAP = {
  'FAC' => '_parse_faceoff',
  'MISS' => '_parse_miss',
  'BLOCK' => '_parse_block',
  'SHOT' => '_parse_shot'
}


class Parse::Game2007 < Parse::Game
  def get_data
    puts @id
    puts 'get_data'
    get_players
    get_shifts
    get_events
    _process_data
  end

  def get_players
    puts 'get_players'
    @box = Nokogiri::HTML(open(BOXSCORE % @id))
    _process_players(@box)
  end

  def get_shifts
    puts 'get_shifts'
    _process_goals(@box)
    home = Nokogiri::HTML(open(HOME_TOI % [Integer(@id[0, 4]), Integer(@id[0, 4]) + 1, @id[4, 6]]))
    _process_shifts(home)
    away = Nokogiri::HTML(open(AWAY_TOI % [Integer(@id[0, 4]), Integer(@id[0, 4]) + 1, @id[4, 6]]))
    _process_shifts(away)
  end

  def get_events
    puts 'get_events'
    events = Nokogiri::HTML(open(EVENTS % [Integer(@id[0, 4]), Integer(@id[0, 4]) + 1, @id[4, 6]]))
    _process_events(events)
    _process_penalties(@box)
  end

  def _process_goals(page)
    puts '_process_goals'
  end

  def _process_players(page)
    page.css('table.gcBoxscorePlayerStats tbody').each_with_index do |table, i|
      table.css('td.left a.undMe').each_with_index do |player, j|
        if not player.nil?
          reg = player['href'].match('[0-9]*$')
          if not reg.nil?
            @p = Player.find_by(nhl_id: Integer(reg[0]))
            if @p.nil?
              @p = Player.new(nhl_id: reg[0])
              @p.retrieve(@p.nhl_id)
              @p.save
            end
            if i < 2
              @away_team.push(@p)
            else
              @home_team.push(@p)
            end
          end
        end
      end
    end
  end

  def _process_shifts(page)
    puts '_process_shifts'
    puts 'process the TOI data'
  end

  def _process_events(page)
    headings = page.css('td.heading')
    @away = headings[6].content.match('[A-Z]{2,3}|[A-Z]\.[A-Z]')[0]
    @home = headings[7].content.match('[A-Z]{2,3}|[A-Z]\.[A-Z]')[0]
    page.css('tr.evenColor').each do |row|
      cells = row.css('td.bborder')
      if not cells.nil?
        type = cells[4].content
        if not EVENT_PARSER_MAP[type].nil?
          event = {
            'game' => @id,
            'period' => Integer(cells[1].content),
            'time' => __time_to_int(cells[3].content.match('^([1-2]?[0-9]:[0-5][0-9])')[0]),
            'event_type' => type
          }
          m = self.method(EVENT_PARSER_MAP[type])
          m.call(event, cells[5].content)
        end
      end
    end
  end

  def _process_penalties(page)
    puts '_process_penalties'
  end

  def _process_data
    puts '_process_data'
  end

  def _parse_faceoff(event, desc)
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

  def _parse_miss(event, desc)
    matches = desc.match('^([A-Z]{2,3}|[A-Z]\.[A-Z]).*#([0-9]{1,2}).*(Neu|Def|Off)\. Zone')
    event['win_team'] = matches[1].eql?(@home) ? @away.delete('.') : @home.delete('.')
    event['player'] = matches[2]
    event['against'] = ''
    puts 'TODO make this the current goalie for the opponent'
    event['zone'] = matches[3][0]
  end

  def _parse_block(event, desc)
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

  def _parse_shot(event, desc)
    matches = desc.match('^([A-Z]{2,3}|[A-Z]\.[A-Z]).*#([0-9]{1,2}).*(Neu|Def|Off)\. Zone')
    event['win_team'] = matches[1].eql?(@away) ? @away.delete('.') : @home.delete('.')
    event['player'] = matches[2]
    event['against'] = ''
    puts 'TODO make this the current goalie for the opponent'
    event['zone'] = matches[3][0]
  end

  def __time_to_int(time)
    matches = time.match('([0-9]*):([0-9]*)')
    min = Integer(matches[1])
    sec = Integer(matches[2].sub(/^0/, ''))
    return (min * 60) + sec
  end
end