defmodule TttServer.GameActorTest do
  use ExUnit.Case

  alias TttServer.GameActor, as: GameActor

  setup do
    {:ok, game} = GameActor.start_link()
    {:ok, gameActor: game}
  end

  test "temporary test: game is won by last player", %{gameActor: game} do
    GameActor.add_player(game, 1)
    GameActor.add_player(game, 2)

    {:ok, _} = GameActor.place_move(game, 1, 1)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 2, 2)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 1, 3)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 2, 4)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 1, 5)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 2, 6)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 1, 7)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 2, 8)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 1, 9)
    {gameStatus, _,_} = GameActor.game_status(game)

    assert gameStatus == :game_over
  end

  test "temporary test: game is won by last player game is closed after both players know the result" , %{gameActor: game}do
    GameActor.add_player(game, 1)
    GameActor.add_player(game, 2)

    {:ok, _} = GameActor.place_move(game, 1, 1)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 2, 2)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 1, 3)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 2, 4)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 1, 5)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 2, 6)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 1, 7)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 2, 8)
    {:game_is_on, _, _} = GameActor.game_status(game)
    {:ok, _} = GameActor.place_move(game, 1, 9)
    {_, _,_} = GameActor.game_status(game, 1)
    {gameStatus, _,_,} = GameActor.game_status(game, 2)

    assert gameStatus == :game_closed
  end

  test "game status is correct after 3 moves" , %{gameActor: game} do
    GameActor.add_player(game, 1)
    GameActor.add_player(game, 2)

    {:ok, _} = GameActor.place_move(game, 1, 1)
    {:ok, _} = GameActor.place_move(game, 2, 5)
    {:ok, _} = GameActor.place_move(game, 1, 8)

    {:game_is_on, _, board} = GameActor.game_status(game)

    assert board[:board] ==
      %{1 => :x, 2 => nil, 3 => nil,
        4 => nil, 5 => :y, 6 => nil,
        7 => nil, 8 => :x, 9 => nil}
  end

  test "initial game status is waiting_for_players", %{gameActor: game} do
    {gameStatus, _, _} = GameActor.game_status(game)

    assert gameStatus == :waiting_for_players
  end

  test "game status after first player joined is waiting_for_players", %{gameActor: game} do
    GameActor.add_player(game, 1)
    {gameStatus, _, _} = GameActor.game_status(game)

    assert gameStatus == :waiting_for_players
  end

  test "game status after second player joined is game_is_on", %{gameActor: game} do
    GameActor.add_player(game, 1)
    GameActor.add_player(game, 2)
    {gameStatus, _, _} = GameActor.game_status(game)

    assert gameStatus == :game_is_on
  end

  test "error is returned at the attempt of adding the third player", %{gameActor: game} do
    GameActor.add_player(game, 1)
    GameActor.add_player(game, 2)

    assert GameActor.add_player(game, 3) == {:error, "Game is started"}
  end

  test "error is returned at the attempt of adding the same player", %{gameActor: game} do
    GameActor.add_player(game, 1)

    assert GameActor.add_player(game, 1) == {:error, "Player already in the game"}
  end

  test "Player places move in invalid position, correct error is returned", %{gameActor: game} do
    GameActor.add_player(game, 1)
    GameActor.add_player(game, 2)

    assert GameActor.place_move(game, 1, 10) == {:invalid_move, "Position does not exist"}
  end

  test "Player places move in filled position, correct error is returned", %{gameActor: game} do
    GameActor.add_player(game, 1)
    GameActor.add_player(game, 2)
    {:ok, _} = GameActor.place_move(game, 1, 1)

    assert GameActor.place_move(game, 2, 1) == {:invalid_move, "Position is already filled"}
  end

  test "Invalid player places correct move, invalid player error is returned", %{gameActor: game} do
    GameActor.add_player(game, 1)
    GameActor.add_player(game, 2)

    assert GameActor.place_move(game, 3, 1) == {:invalid_player, nil}
  end

  test "Player places correct move on wrong turn, invalid player error is returned", %{gameActor: game} do
    GameActor.add_player(game, 1)
    GameActor.add_player(game, 2)
    GameActor.place_move(game, 1, 1)

    assert GameActor.place_move(game, 1, 2) == {:invalid_player, "Wait your turn"}
  end

end
