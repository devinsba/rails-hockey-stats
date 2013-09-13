require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  test "Bergy is God" do
    player = Player.new(nhl_id: 8470638)
    player.retrieve(player.nhl_id)
    assert player.first_name.eql?("Patrice")
    assert player.last_name.eql?("Bergeron")
  end
end
