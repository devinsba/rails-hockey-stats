
desc "This task retrieves a list of todays games and drops them into the processing queue"
task :update_games => :environment do
  puts "Updating games..."
  # eventually send in Time.new
  day = Parse::Day.new(Time.new(2013, 3, 9))
  day.parse.each do |id|
    parser = Parse::GameFactory.new.get_parser(id)
    parser.run
  end
  puts "done."
end

task :historic_games => :environment do
  puts "Queueing up historic_games processing..."
  puts "done."
end
