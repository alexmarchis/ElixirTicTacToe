defmodule TttServer.GameStateCalculator do
  def calculate_state(board) do
    checks = [&check_rows/1,
              &check_columns/1,
              &check_left_diagonal/1,
              &check_right_diagonal/1]

    case Enum.find_value(checks, fn check -> check.(board) end) do
      nil ->
        if (Enum.all?(Map.values(board), fn slot -> slot != nil end)) do
          {:game_over, nil}
        else
          {:game_is_on, nil}
        end
      symbol -> {:game_over, symbol}
    end
  end

  defp check_rows(board) do
    rowResults = for row <- 0..2 do
      [firstSymbol|restOfTheRow] = 1..3 |> Enum.map(fn column -> board[row*3 + column] end)
      if restOfTheRow |> Enum.all?(fn symbol -> firstSymbol == symbol end) do
        firstSymbol
      end
    end

    rowResults |> Enum.find(fn result -> result != nil end)
  end

  defp check_columns(board) do
    columnResults = for column <- 1..3 do
      [firstSymbol|restOfTheColumn] = 0..2 |> Enum.map(fn row -> board[row*3 + column] end)
      if restOfTheColumn |> Enum.all?(fn symbol -> firstSymbol == symbol end) do
        firstSymbol
      end
    end

    columnResults |> Enum.find(fn result -> result != nil end)
  end

  defp check_left_diagonal(board) do
    [firstSymbol|restOfTheDiagonal] = 1..3 |> Enum.map(fn row -> board[(row-1)*3 + row] end)
    if restOfTheDiagonal |> Enum.all?(fn symbol -> firstSymbol == symbol end) do
      firstSymbol
    else
      nil
    end
  end

  defp check_right_diagonal(board) do
    [firstSymbol|restOfTheDiagonal] = 1..3 |> Enum.map(fn row -> board[(row-1)*3 + (4 - row)] end)
    if restOfTheDiagonal |> Enum.all?(fn symbol -> firstSymbol == symbol end) do
      firstSymbol
    else
      nil
    end
  end
end
