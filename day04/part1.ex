defmodule M do
  def solve do
    IO.read(:stdio, :all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.flat_map(&(String.split(&1, ":") |> Enum.drop(1)))
    |> Enum.map(fn s ->
      String.split(s, "|")
      |> Enum.map(
        &(String.split(&1)
          |> Enum.reduce(MapSet.new(), fn v, acc -> acc |> MapSet.put(v) end))
      )
    end)
    |> Enum.map(fn [s1, s2] -> MapSet.intersection(s1, s2) |> MapSet.size() end)
    |> Enum.map(&(:math.pow(2, &1) |> trunc |> div(2)))
    |> Enum.sum()
  end
end

IO.puts(M.solve())
