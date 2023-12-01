defmodule M do
  def first_digit(s) do
    [head | tail] = String.graphemes(s)

    case Integer.parse(head) do
      {x, ""} -> x
      _ -> first_digit(Enum.join(tail))
    end
  end

  def solve do
    IO.read(:stdio, :all)
    |> String.trim()
    |> String.split()
    |> Enum.map(&"#{first_digit(&1)}#{first_digit(String.reverse(&1))}")
    |> Enum.map(fn x ->
      {x, ""} = Integer.parse(x)
      x
    end)
    |> Enum.sum()
  end
end

IO.puts(M.solve())
