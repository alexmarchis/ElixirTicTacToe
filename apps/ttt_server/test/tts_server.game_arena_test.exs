defmodule TttServer.GameArenaTests do
  use ExUnit.Case, async: false
  alias TttServer.GameArena, as: GameArena

  setup context do
    {:ok, arena} = GameArena.start_link(context.test)
    {:ok, gameArena: arena}
  end

  test "get player by name", %{gameArena: arena} do
    assert GameArena.get_player(arena, "Ghita") == 1
    assert GameArena.get_player(arena, "Ghita") == 1
    assert GameArena.get_player(arena, "Alex") == 2
    assert GameArena.get_player(arena, "Alex") == 2
  end

  test "one player entered game, status is waiting_for_players", %{gameArena: arena} do
    assert GameArena.get_player(arena, "Ghita") == 1
    assert GameArena.find_game(arena, 1) == {:ok, 1}

    assert GameArena.get_game_status(arena, 1,1) == {:ok, {:waiting_for_players, nil, nil}}
  end

  test "find_game creates game and adds players", %{gameArena: arena} do
    assert GameArena.get_player(arena, "Ghita") == 1
    assert GameArena.get_player(arena, "Alex") == 2
    assert GameArena.get_player(arena, "Ion") == 3
    assert GameArena.find_game(arena, 1) == {:ok, 1}
    assert GameArena.find_game(arena, 2) == {:ok, 1}
    assert GameArena.find_game(arena, 3) == {:ok, 2}
  end

  test "find_game called with invalid player will not create game", %{gameArena: arena} do
    assert GameArena.find_game(arena, 1) == {:error, "Invalid player id"}
  end

  test "2 players join a game and one move is placed, game status is as expected ", %{gameArena: arena} do
    ghitaId = GameArena.get_player(arena, "Ghita")
    alexId = GameArena.get_player(arena, "Alex")

    {:ok, gameId} = GameArena.find_game(arena, alexId)
    assert GameArena.find_game(arena, ghitaId) == {:ok, gameId}

    assert GameArena.place_move(arena, gameId, alexId, 1) == {:ok, "Good move"}
    assert GameArena.place_move(arena, gameId, ghitaId, 5) == {:ok, "Good move"}
    assert GameArena.place_move(arena, gameId, alexId, 8) == {:ok, "Good move"}

    {:ok, {:game_is_on, _, gameState}} = GameArena.get_game_status(arena, gameId, alexId)

    assert gameState[:board] ==
      %{1 => :x, 2 => nil, 3 => nil,
        4 => nil, 5 => :y, 6 => nil,
        7 => nil, 8 => :x, 9 => nil}

  end

  test "Player wins, game is closed after both players get status", %{gameArena: arena} do
    ghitaId = GameArena.get_player(arena, "Ghita")
    alexId = GameArena.get_player(arena, "Alex")

    {:ok, gameId} = GameArena.find_game(arena, alexId)
    assert GameArena.find_game(arena, ghitaId) == {:ok, gameId}

    assert GameArena.place_move(arena, gameId, alexId, 1) == {:ok, "Good move"}
    assert GameArena.place_move(arena, gameId, ghitaId, 5) == {:ok, "Good move"}
    assert GameArena.place_move(arena, gameId, alexId, 7) == {:ok, "Good move"}
    assert GameArena.place_move(arena, gameId, ghitaId, 2) == {:ok, "Good move"}
    assert GameArena.place_move(arena, gameId, alexId, 4) == {:ok, "Good move"}

    {:ok, {:game_over, ^alexId, _gameState}} = GameArena.get_game_status(arena, gameId, alexId)
    {:ok, {:game_over, ^alexId, _gameState}} = GameArena.get_game_status(arena, gameId, ghitaId)

    assert GameArena.get_game_status(arena, gameId, alexId) == {:error, "Invalid game or player"}

  end

  test "Player wins, players have correct statistics", %{gameArena: arena} do
    ghitaId = GameArena.get_player(arena, "Ghita")
    alexId = GameArena.get_player(arena, "Alex")

    {:ok, gameId} = GameArena.find_game(arena, alexId)
    assert GameArena.find_game(arena, ghitaId) == {:ok, gameId}

    assert GameArena.place_move(arena, gameId, alexId, 1) == {:ok, "Good move"}
    assert GameArena.place_move(arena, gameId, ghitaId, 5) == {:ok, "Good move"}
    assert GameArena.place_move(arena, gameId, alexId, 7) == {:ok, "Good move"}
    assert GameArena.place_move(arena, gameId, ghitaId, 2) == {:ok, "Good move"}
    assert GameArena.place_move(arena, gameId, alexId, 4) == {:ok, "Good move"}

    {:ok, {:game_over, ^alexId, _gameState}} = GameArena.get_game_status(arena, gameId, alexId)
    {:ok, {:game_over, ^alexId, _gameState}} = GameArena.get_game_status(arena, gameId, ghitaId)

    assert GameArena.get_player_statistics(arena, alexId) == {:ok, [games_won: 1, games_lost: 0]}
    assert GameArena.get_player_statistics(arena, ghitaId) == {:ok, [games_won: 0, games_lost: 1]}
  end
end
