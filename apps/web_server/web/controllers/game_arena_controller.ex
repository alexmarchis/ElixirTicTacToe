defmodule WebServer.GameArenaController do
  use WebServer.Web, :controller
  alias TttServer.GameArena, as: Arena

  #post "/gamearena/player/:name", GameArenaController, :get_player
  def get_player(conn, %{"name" => playerName}) do
    case Arena.get_player(GameArena, playerName) do
      :error -> json conn, %{operation: "Failed", playerId: nil}
      playerId -> json conn, %{operation: "Succesful", playerId: playerId}
    end
  end

  #post "/gamearena/game/:playerId", GameArenaController, :find_game
  def find_game(conn, params) do
    %{"playerId" => playerId} = to_ints(params)

    case Arena.find_game(GameArena, playerId) do
      {:ok, gameId} -> json conn, %{operation: "Successful", gameId: gameId}
      {:error, errorMessage} -> json conn, %{operation: errorMessage, gameId: nil}
    end
  end

  #post "/gamearena/game/place_move/:gameId/:playerId/:position", GameArenaController, :place_move
  def place_move(conn, params) do
    IO.inspect params
    %{"gameId" => gameId, "playerId" => playerId, "position" => position} = to_ints(params)

    case Arena.place_move(GameArena, gameId, playerId, position) do
      {:ok, message} -> json conn, %{operation: "Successful", message: message}
      {errorType, errorMessage} -> json conn, %{operation: errorType, message: errorMessage}
      :error -> json conn, %{operation: "Failed", message: nil}
    end
  end

  #post "/gamearena/game/get_status/:gameId/:playerId", GameArenaController, :get_status
  def get_status(conn, params) do
    %{"gameId" => gameId, "playerId" => playerId} = to_ints(params)

    case Arena.get_game_status(GameArena, gameId, playerId) do
      {:ok, {status, winnerId, state}} ->
        IO.inspect state
        json conn, %{operation: "Successful", status: status, winner_id: winnerId, current_board: serializable_board(state[:board])}
      {:error, errorMessage} -> json conn, %{operation: "Failed", message: errorMessage}
    end
  end

  #get "/gamearena/player/statistics/:playerId", GameArenaController, :get_player_statistics
  def get_player_statistics(conn, params) do
    %{"playerId" => playerId} = to_ints(params)

    case Arena.get_player_statistics(GameArena, playerId) do
      {:ok, statistics} -> json conn, %{operation: "Successful", statistics: serializable_statistics(statistics)}
      {:error, errorMessage} -> json conn, %{operation: "Failed", message: errorMessage}
      {errorType, errorMessage} -> json conn, %{operation: errorType, message: errorMessage}
    end
  end

  defp to_ints(parameters) do
    Enum.map(parameters, fn {paramName, value} ->
        {intValue, _} = Integer.parse(value)
        {paramName, intValue} end)
    |> Enum.into(%{})
  end

  defp serializable_board(nil) ,do: nil
  defp serializable_board(board) do
    Enum.map(board, fn {position, symbol} ->
        {to_string(position), symbol} end)
    |> Enum.into(%{})
  end

  defp serializable_statistics(statistics) do
    statistics
    |> Enum.into(%{})
  end
end
