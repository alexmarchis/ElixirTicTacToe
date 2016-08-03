defmodule TttServer.GameActor do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok)
  end

  def stop_game(gamePid) do
    GenServer.stop(gamePid, :normal)
  end

  def place_move(gamePid, playerId, position) do
    GenServer.call(gamePid, {:place_move, playerId, position})
  end

  def add_player(gamePid, playerId) do
    GenServer.call(gamePid, {:add_player, playerId})
  end

  def game_status(gamePid, playerId) do
    GenServer.call(gamePid, {:game_status, playerId})
  end

  def game_status(gamePid) do
    GenServer.call(gamePid, {:game_status})
  end

  def init(:ok) do
    initialGameState = new_game()
    {:ok, initialGameState}
  end

  def handle_call({:place_move, playerId, position}, _from, gameState) do
    case with  {:game_is_on, _symbol}  	  <- get_game_status(gameState),
          {:ok, playerSymbol}         <- get_player_symbol(gameState[:players], playerId),
          {:ok, _}                    <- check_player_turn(gameState, playerSymbol),
          {:ok, board}                <- place_player_symbol(gameState[:board], position, playerSymbol),
          do: {:ok, "Good move", gameState |> Keyword.put(:board, board) |> Keyword.put(:last_move, playerSymbol)} do

            {:ok, message, newGameState} -> {:reply, {:ok, message}, newGameState }
            error_message -> {:reply, error_message, gameState }
    end
  end

  def handle_call({:add_player, playerId}, _from, gameState) do
    case gameState[:players] do
      [x: nil, y: nil] ->
        newGameState = gameState |>
          Keyword.put(:players, [x: {playerId, false}, y: nil])
        {:reply, {:ok, "Player added"}, newGameState}
      [x: {^playerId, _announced} , y: nil] -> {:reply, {:error, "Player already in the game"}, gameState}
      [x: {xPlayer, _announced}, y: nil] ->
        newGameState = gameState |>
          Keyword.put(:players, [x: {xPlayer, false}, y: {playerId, false}])
        {:reply, {:ok, "Player added, game is started."}, newGameState}
      [x: _, y: _] -> {:reply, {:error, "Game is started"}, gameState}
    end
  end

  def handle_call({:game_status, playerId}, _from, gameState) do
    case get_game_status(gameState) do
      {:game_is_on, _symbol} -> {:reply, {:game_is_on, nil, gameState}, gameState}
      {:game_over, winningSymbol} ->
        {:ok, playerSymbol} = get_player_symbol(gameState[:players], playerId)
        announcedPlayers = Keyword.put(gameState[:players], playerSymbol, {playerId, true})
        newGameState = gameState |> Keyword.put(:players, announcedPlayers)

        {winnerId, _announced} = gameState[:players][winningSymbol]

        if Enum.all?(announcedPlayers, fn {_symbol, {_playerId, announced}} -> announced==true end) do
          {:reply, {:game_closed, winnerId, newGameState}, newGameState}
        else
          {:reply, {:game_over, winnerId, newGameState}, newGameState}
        end
    end
  end

  def handle_call({:game_status}, _from, gameState) do
    message = get_game_status(gameState)
    {:reply, Tuple.append(message, gameState), gameState}
  end

  defp get_game_status(gameState) do
    if(gameState[:players][:x] == nil
    || gameState[:players][:y] == nil) do
      {:waiting_for_players, nil}
    else
      board_winning_state(gameState[:board])
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
