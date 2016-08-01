defmodule TttServer.GameArena do
  use GenServer

  def start_link(name) do
    IO.puts("Starting game arena...")
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def get_player(server, playerName) do
    GenServer.call(server, {:get_player, playerName})
  end

  def find_game(server, playerId) do
    GenServer.call(server, {:find_game, playerId})
  end

  def place_move(server, gameId, playerId, position) do
    GenServer.call(server, {:place_move, gameId, playerId, position})
  end

  def get_game_status(server, gameId, playerId) do
    GenServer.call(server, {:get_game_status, gameId, playerId})
  end

  def get_player_statistics(server, playerId) do
    GenServer.call(server, {:get_player_statistics, playerId})
  end

  ## Server Callbacks

  def init(:ok) do
    players = %{}
    games = %{}
    {:ok, {players, games}}
  end

  def handle_call({:get_player, playerName}, _from, {players, games}) do
    case players |> Enum.find(fn {_playerId, player} -> player.playerName == playerName end) do
      {playerId, _playerName} -> {:reply, playerId, {players, games}}
      nil ->
        nextPlayerId = players |> Map.keys |> generate_id
        {:reply, nextPlayerId, {Map.put(players, nextPlayerId, %TttServer.Player{playerId: nextPlayerId, playerName: playerName}), games}}
        _ -> {:reply, :error, {players, games}}
    end
  end

  def handle_call({:find_game, playerId}, _from, {players, games}) do
    if Map.has_key?(players, playerId) do
      case games |> Enum.find(fn {_gameId, game} -> try_add_player(game, playerId) end) do
        {gameId, _} ->
          {:reply, {:ok, gameId}, {players, games}}
        nil ->
          nextGameId = games |> Map.keys |> generate_id
          game = create_game(nextGameId)

          if try_add_player(game, playerId) do
            {:reply, {:ok, nextGameId}, {players, Map.put(games, nextGameId, game)}}
          else
            {:reply, {:error, "No game found, try again..."}, {players, Map.put(games, nextGameId, game)}}
          end
      end
    else
      {:reply, {:invalid_player, "Invalid player id"}, {players, games}}
    end
  end

  def handle_call({:place_move, gameId, playerId, position}, _from, {players, games}) do
      message =
        with {:ok, player} <- Map.fetch(players, playerId),
             {:ok, game} <- Map.fetch(games, gameId),
             do: TttServer.GameActor.place_move(game.gamePid, player.playerId, position)

      {:reply, message, {players, games}}
  end

  def handle_call({:get_game_status, gameId, playerId}, _from, {players, games}) do
    case with  {:ok, player} <- Map.fetch(players, playerId),
            {:ok, game} <- Map.fetch(games, gameId),
            do: handle_game_status(gameId, game.gamePid, playerId, games) do
      :error                  -> {:reply, "Invalid game or player", {players, games}}
      {updatedGames, message} -> {:reply, message, {players, updatedGames}}
    end
  end

  def handle_call({:get_player_statistics, playerId}, _from, {players, games}) do
    #TODO
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp try_add_player(game, playerId) do
     case TttServer.GameActor.add_player(game.gamePid, playerId) do
       {:ok, _} -> true
       {:error, _} -> false
     end
  end

  defp create_game(gameId) do
    {:ok, gamePid} = TttServer.Game.Supervisor.start_game()
    %TttServer.Game{gameId: gameId, gamePid: gamePid}
  end

  defp generate_id([]), do: 1;
  defp generate_id(ids), do: Enum.max(ids) + 1;

  defp handle_game_status(gameId, gamePid, playerId, games) do
    case TttServer.GameActor.game_status(gamePid, playerId) do
      {:game_is_on, _noWinnerId, gameState} -> {games, {:game_is_on, nil, gameState}}
      {:game_over, winningPlayerId, gameState} -> {games, {:game_over, winningPlayerId, gameState}}
      {:game_closed, winningPlayerId, gameState} ->
        update_players(gameState, winningPlayerId)
        updatedGames = end_game(gameId, gamePid, games)
        {updatedGames, {:game_over, winningPlayerId, gameState}}
    end
  end

  defp update_players(gameState, winningPlayerId) do

  end

  defp end_game(gameId, gamePid, games) do
    IO.puts "ending game"
    TttServer.GameActor.stop_game(gamePid)
    Map.delete(games, gameId)
  end
end
