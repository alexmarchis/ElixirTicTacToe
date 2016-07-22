defmodule TttServer.Game do
  defstruct gameId: -1, gamePid: nil

  def start_link, do: Agent.start_link fn -> new_game end;

  def place_move(gamePid, playerId, position) do
    with  {:game_is_on, _, gameState} <- game_status(gamePid),
          {:ok, playerSymbol}         <- get_player_symbol(gameState[:players], playerId),
          {:ok, _}                    <- check_player_turn(gameState, playerSymbol),
          {:ok, board}                <- place_player_symbol(gameState[:board], position, playerSymbol),
          :ok                         <- Agent.update(gamePid, fn [players: players, board: _, last_move: _] ->
                                                                  [players: players, board: board, last_move: playerSymbol] end),
          do: {:ok, "Good move"}
  end

  def add_player(gamePid, playerId) do
    gameState = Agent.get(gamePid, fn map -> map end )
    case gameState[:players] do
      [x: nil, y: nil] ->
        Agent.update(gamePid, fn [players: _, board: board, last_move: last_move] ->
                                 [players: [x: playerId, y: nil], board: board, last_move: last_move] end)
        {:ok, "Player added"}
      [x: ^playerId, y: nil] -> {:error, "Player already in the game"}
      [x: xPlayer, y: nil] ->
        Agent.update(gamePid, fn [players: _, board: board, last_move: last_move] ->
                                 [players: [x: xPlayer, y: playerId], board: board, last_move: last_move] end)
        {:ok, "Player added, game is started."}
      [x: _, y: _] -> {:error, "Game is started"}
    end
  end

  def game_status(gamePid) do
    gameState = Agent.get(gamePid, fn map -> map end )
    if(gameState[:players][:x] == nil
    || gameState[:players][:y] == nil) do
      {:waiting_for_players, "Don't be shy", nil}
    else
      if(game_won?(gameState[:board])) do
        {:game_won, "Congrats", gameState}
      else
        {:game_is_on, "Keep playing", gameState}
      end
    end
  end

  defp get_player_symbol(players, playerId) do
    case Enum.find(players, fn {_, searchedPlayerId} -> searchedPlayerId == playerId end) do
      nil               -> {:invalid_player, nil}
      {playerSymbol, _} -> {:ok, playerSymbol}
    end
  end

  defp check_player_turn(gameState, symbol) do
    case gameState[:last_move] != symbol do
      true  -> {:ok, nil}
      false -> {:invalid_player, "Wait your turn"}
    end
  end

  defp place_player_symbol(_board, _position, :invalid_player) do
    {:invalid_player, "Player is not from this game"}
  end

  defp place_player_symbol(board, position, playerSymbol) do
    case Map.get(board, position, :invalid_position) do
      nil               -> {:ok, Map.update!(board, position, fn _ -> playerSymbol end)}
      :invalid_position -> {:invalid_move, "Position does not exist"}
      _                 -> {:invalid_move, "Position is already filled"}
    end
  end

  defp game_won?(board) do
    Enum.all?(board, fn {_, elem} -> elem != nil end)
  end

  defp new_game do
    [players: [x: nil, y: nil], board: empty_board, last_move: nil]
  end

  defp empty_board do
    %{1 => nil, 2 => nil, 3 => nil,
      4 => nil, 5 => nil, 6 => nil,
      7 => nil, 8 => nil, 9 => nil}
  end
end
