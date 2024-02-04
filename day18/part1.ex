defmodule P do
  def add({px1, py1}, {px2, py2}), do: {px1 + px2, py1 + py2}

  def prod({px, py}, k), do: {px * k, py * k}

  def module({px, py}), do: abs(px) + abs(py)

  def manhattan(p1, p2), do: module(p2 |> add(p1 |> prod(-1)))
end

defmodule M do
  defp shoelace(l) do
    mx = l |> Enum.reduce(%{}, fn {x, _}, m -> m |> Map.put(m |> map_size(), x) end)
    my = l |> Enum.reduce(%{}, fn {_, y}, m -> m |> Map.put(m |> map_size(), y) end)
    l = length(l)

    0..(l - 1)
    |> Enum.reduce(0, fn i, acc ->
      acc + mx[i] * my[rem(i + 1, l)] - mx[rem(i + 1, l)] * my[i]
    end)
    |> div(2)
  end

  defp perimeter([], _, n), do: n

  defp perimeter([h | t], p, n) do
    perimeter(t, h, n + P.manhattan(p, h))
  end

  defp perimeter(l), do: perimeter(l, {0, 0}, 0)

  def solve do
    dirs = %{"U" => {0, -1}, "D" => {0, 1}, "L" => {-1, 0}, "R" => {1, 0}}

    l =
      IO.read(:all)
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.split/1)
      |> Enum.map(fn [d, n, _] -> {d, n |> String.to_integer()} end)
      |> Enum.reduce({{0, 0}, []}, fn {d, n}, {p, l} ->
        p = p |> P.add(dirs[d] |> P.prod(n))
        {p, l ++ [p]}
      end)
      |> elem(1)

    shoelace(l) + (perimeter(l) |> div(2)) + 1
  end
end

M.solve() |> IO.puts()
