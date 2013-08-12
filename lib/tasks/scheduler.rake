desc "This task is called by the Heroku scheduler add-on"
task :update_games => :environment do
	puts "Updating games..."
	puts "done."
end