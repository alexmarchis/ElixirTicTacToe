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

  test "find_game creates game and adds players", %{gameArena: arena} do
    assert GameArena.get_player(arena, "Ghita") == 1
    assert GameArena.get_player(arena, "Alex") == 2
    assert GameArena.get_player(arena, "Ion") == 3
    assert GameArena.find_game(arena, 1) == {:ok, 1}
    assert GameArena.find_game(arena, 2) == {:ok, 1}
    assert GameArena.find_game(arena, 3) == {:ok, 2}
  end

  test "find_game called with invalid player will not create game", %{gameArena: arena} do
    assert GameArena.find_game(arena, 1) == {:invalid_player, "Invalid player id"}
  end

  test "2 players join a game and one move is placed, game status is as expected ", %{gameArena: arena} do
    ghitaId = GameArena.get_player(arena, "Ghita")
    alexId = GameArena.get_player(arena, "Alex")

    {:ok, gameId} = GameArena.find_game(arena, alexId)
    assert GameArena.find_game(arena, ghitaId) == {:ok, gameId}

    assert GameArena.place_move(arena, gameId, alexId, 1) == {:ok, "Good move"}
    assert GameArena.place_move(arena, gameId, ghitaId, 5) == {:ok, "Good move"}
    assert GameArena.place_move(arena, gameId, alexId, 8) == {:ok, "Good move"}

    {:game_is_on, _, gameState} = GameArena.get_game_status(arena, gameId, alexId)

    assert gameState[:board] ==
      %{1 => :x, 2 => nil, 3 => nil,
        4 => nil, 5 => :y, 6 => nil,
        7 => nil, 8 => :x, 9 => nil}

  end
end
