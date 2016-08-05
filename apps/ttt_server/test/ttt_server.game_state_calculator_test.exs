defmodule TttServer.GameStateCalculatorTest do
  use ExUnit.Case

  alias TttServer.GameStateCalculator, as: Calculator

  test "Game is not over, returns game_is_on" do
    board = %{1 => :x, 2 => nil, 3 => nil,
              4 => nil, 5 => :y, 6 => nil,
              7 => nil, 8 => :x, 9 => nil}

    assert Calculator.calculate_state(board) == {:game_is_on, nil}
  end

  test "Game is a draw, returns game_over with nil winner" do
    board = %{1 => :x, 2 => :x, 3 => :y,
              4 => :y, 5 => :y, 6 => :x,
              7 => :x, 8 => :x, 9 => :y}

    assert Calculator.calculate_state(board) == {:game_over, nil}
  end

  test "Game is won with first column filled, returns game_over with correct winner" do
    board = %{1 => :x, 2 => nil, 3 => :y,
              4 => :x, 5 => :y, 6 => nil,
              7 => :x, 8 => :x, 9 => :y}

    assert Calculator.calculate_state(board) == {:game_over, :x}
  end

  test "Game is won with middle column filled, returns game_over with correct winner" do
    board = %{1 => nil, 2 => :x, 3 => :y,
              4 => :y, 5 => :x, 6 => nil,
              7 => :x, 8 => :x, 9 => :y}

    assert Calculator.calculate_state(board) == {:game_over, :x}
  end

  test "Game is won with right column filled, returns game_over with correct winner" do
    board = %{1 => nil, 2 => :y, 3 => :x,
              4 => :y, 5 => nil, 6 => :x,
              7 => :x, 8 => :y, 9 => :x}

    assert Calculator.calculate_state(board) == {:game_over, :x}
  end

  test "Game is won with first row filled, returns game_over with correct winner" do
    board = %{1 => :x, 2 => :x, 3 => :x,
              4 => :x, 5 => :y, 6 => nil,
              7 => :y, 8 => nil, 9 => :y}

    assert Calculator.calculate_state(board) == {:game_over, :x}
  end

  test "Game is won with middle row filled, returns game_over with correct winner" do
    board = %{1 => nil, 2 => :y, 3 => :y,
              4 => :x, 5 => :x, 6 => :x,
              7 => :x, 8 => nil, 9 => :y}

    assert Calculator.calculate_state(board) == {:game_over, :x}
  end

  test "Game is won with bottom row filled, returns game_over with correct winner" do
    board = %{1 => nil, 2 => :y, 3 => :y,
              4 => :y, 5 => nil, 6 => :x,
              7 => :x, 8 => :x, 9 => :x}

    assert Calculator.calculate_state(board) == {:game_over, :x}
  end

  test "Game is won with left diagonal filled, returns game_over with correct winner" do
    board = %{1 => :y, 2 => :x, 3 => :x,
              4 => :y, 5 => :y, 6 => :x,
              7 => :x, 8 => :x, 9 => :y}

    assert Calculator.calculate_state(board) == {:game_over, :y}
  end

  test "Game is won with left diagonal filled, returns game_over with correct winner" do
    board = %{1 => :y, 2 => :x, 3 => :y,
              4 => :x, 5 => :y, 6 => :x,
              7 => :y, 8 => :x, 9 => :x}

    assert Calculator.calculate_state(board) == {:game_over, :y}
  end
end
