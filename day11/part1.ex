defmodule M do
  defp dist([c0, c1], hs) do
    n = c0..c1 |> Enum.filter(fn c -> not (hs |> MapSet.member?(c)) end) |> Enum.count()
    abs(c0 - c1) + n
  end

  defp combinaisons([], acc), do: acc

  defp combinaisons([h | t], acc) do
    combinaisons(t, acc ++ Enum.reduce(t, [], fn e, acc -> acc ++ [[h, e]] end))
  end

  def solve() do
    IO.read(:all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim(&1))
    |> Enum.with_index()
    |> Enum.flat_map(fn {s, y} ->
      s
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {c, _} -> c == "#" end)
      |> Enum.map(fn {_, x} -> {x, y} end)
    end)
    |> Enum.unzip()
    |> Tuple.to_list()
    |> Enum.map(fn l ->
      hs = l |> Enum.reduce(MapSet.new(), fn e, acc -> acc |> MapSet.put(e) end)

      l
      |> combinaisons([])
      |> Enum.map(&dist(&1, hs))
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end

M.solve() |> IO.puts()
