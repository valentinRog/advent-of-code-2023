defmodule M do
  defp next_line(l) do
    l |> Enum.chunk_every(2, 1, :discard) |> Enum.map(fn [lhs, rhs] -> rhs - lhs end)
  end

  defp compute(l) do
    case l |> Enum.all?(&(&1 == 0)) do
      true -> 0
      false -> (l |> Enum.at(0)) - compute(next_line(l))
    end
  end

  def solve do
    IO.read(:stdio, :all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn s -> s |> String.split() |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(&compute/1)
    |> Enum.sum()
  end
end

IO.puts(M.solve())
