class Parse::GameFactory
  def get_parser(id)
    # can get away with this because any exceptions will already be in the cases
    this_year = Integer(Time.new.year)
    year = Integer(id[0,4])

    case year
    when 2007..this_year
      return Parse::Game2007.new(id)
    end
  end
end