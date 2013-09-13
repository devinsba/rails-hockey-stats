class Parse::Game
  def initialize(id)
    @id = id
    @away_team = []
    @home_team = []
  end

  def run
    get_data
  end
  handle_asynchronously :run

  def get_data
    raise 'Subtype did not implement get_data method'
  end
end
