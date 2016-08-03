defmodule TttServer.PlayerTest do
  use ExUnit.Case

  test "player has no statistics yet, empty statistics are returned" do
    {:ok, player} = TttServer.Player.start_link()

    assert TttServer.Player.get_player_statistics(player) == [games_won: 0, games_lost: 0]
  end

  test "player has 2 games won, correct statistics returned" do
    {:ok, player} = TttServer.Player.start_link()

    TttServer.Player.game_won(player)
    TttServer.Player.game_won(player)

    assert TttServer.Player.get_player_statistics(player) == [games_won: 2, games_lost: 0]
  end

  test "player has 2 games lost, correct statistics returned" do
    {:ok, player} = TttServer.Player.start_link()

    TttServer.Player.game_lost(player)
    TttServer.Player.game_lost(player)

    assert TttServer.Player.get_player_statistics(player) == [games_won: 0, games_lost: 2]
  end
end
