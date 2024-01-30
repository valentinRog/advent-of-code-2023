defmodule M do
  def solve do
    IO.read(:all)
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&Enum.reduce(&1, 0, fn c, n -> rem((n + c) * 17, 256) end))
    |> Enum.sum()
  end
end

M.solve() |> IO.puts()
