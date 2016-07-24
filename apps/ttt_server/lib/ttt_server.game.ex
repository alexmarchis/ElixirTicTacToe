defmodule TttServer.Game do
  defstruct gameId: -1, gamePid: nil

  def start_link do
    Agent.start_link fn -> new_game end
  end

  def stop_game(gamePid) do
    Agent.stop(gamePid, :normal) 
  end

  def place_move(gamePid, playerId, position) do
    with  {:game_is_on, _symbol, gameState} <- game_status(gamePid),
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
                                 [players: [x: {playerId, false}, y: nil], board: board, last_move: last_move] end)
        {:ok, "Player added"}
      [x: {^playerId, _announced} , y: nil] -> {:error, "Player already in the game"}
      [x: {xPlayer, _announced}, y: nil] ->
        Agent.update(gamePid, fn [players: _, board: board, last_move: last_move] ->
                                 [players: [x: {xPlayer, false}, y: {playerId, false}], board: board, last_move: last_move] end)
        {:ok, "Player added, game is started."}
      [x: _, y: _] -> {:error, "Game is started"}
    end
  end

  def game_status(gamePid, playerId) do
    case game_status(gamePid) do
      {:game_is_on, _symbol, gameState} -> {:game_is_on, "Keep playing", gameState}
      {:game_over, winningSymbol, gameState} ->
        {:ok, playerSymbol} = get_player_symbol(gameState[:players], playerId)
        announcedPlayers = Keyword.put(gameState[:players], playerSymbol, {playerId, true})
        Agent.update(gamePid, fn [players: players, board: board, last_move: last_move] ->
                                 [players: announcedPlayers, board: board, last_move: last_move] end)

        {winnerId, _announced} = gameState[:players][winningSymbol]

        if Enum.all?(announcedPlayers, fn {_symbol, {_playerId, announced}} -> announced==true end) do
          {:game_closed, winnerId, gameState}
        else
          {:game_over, winnerId, gameState}
        end
    end
  end

  def game_status(gamePid) do
    gameState = Agent.get(gamePid, fn map -> map end )
    if(gameState[:players][:x] == nil
    || gameState[:players][:y] == nil) do
      {:waiting_for_players, "Don't be shy", nil}
    else
      {winningState, winningSymbol} = board_winning_state(gameState[:board])
      {winningState, winningSymbol, gameState}
    end
  end

  defp get_player_symbol(players, playerId) do
    case Enum.find(players, fn {_symbol, {searchedPlayerId, _announced}} -> searchedPlayerId == playerId end) do
      nil               -> {:invalid_player, nil}
      {playerSymbol, _player} -> {:ok, playerSymbol}
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

  defp board_winning_state(board) do
    if Enum.all?(board, fn {_, elem} -> elem != nil end) do
      {:game_over, :x}
    else
      if board ==
        %{1 => :x, 2 => :y, 3 => nil,
          4 => :x, 5 => :y, 6 => nil,
          7 => :x, 8 => nil, 9 => nil} do
            {:game_over, :x}
      else
        {:game_is_on, nil}
      end
    end
  end

  defp new_game do
    [players: [x: nil, y: nil],
     board: empty_board,
     last_move: nil]
  end

  defp empty_board do
    %{1 => nil, 2 => nil, 3 => nil,
      4 => nil, 5 => nil, 6 => nil,
      7 => nil, 8 => nil, 9 => nil}
  end
end
