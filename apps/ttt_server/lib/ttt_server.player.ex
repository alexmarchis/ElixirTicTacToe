defmodule TttServer.Player do
  defstruct playerId: -1, playerName: "Anon", playerPid: nil, processRef: nil 

  def start_link do
    Agent.start_link fn -> empty_statistics end
  end

  def game_won(playerPid) do
    Agent.update(playerPid, fn [games_won: gamesWon, games_lost: gamesLost] ->
                             [games_won: gamesWon + 1, games_lost: gamesLost] end)
  end

  def game_lost(playerPid) do
    Agent.update(playerPid, fn [games_won: gamesWon, games_lost: gamesLost] ->
                             [games_won: gamesWon, games_lost: gamesLost + 1] end)
  end

  def get_player_statistics(playerPid) do
    Agent.get(playerPid, fn statistics -> statistics end)
  end

  defp empty_statistics do
    [games_won: 0,
     games_lost: 0]
  end
end
