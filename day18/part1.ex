defmodule P do
  def add({px1, py1}, {px2, py2}), do: {px1 + px2, py1 + py2}
end

defmodule M do
  defp compute(m, p, cache) do
    cond do
      cache |> MapSet.member?(p) ->
        MapSet.new()

      m |> MapSet.member?(p) ->
        MapSet.new()

      true ->
        [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
        |> Enum.reduce(cache |> MapSet.put(p), fn d, cache ->
          cache |> MapSet.union(compute(m, p |> P.add(d), cache))
        end)
    end
  end

  defp compute(m), do: compute(m, {1, 1}, MapSet.new())

  def solve do
    dirs = %{"U" => {0, -1}, "D" => {0, 1}, "L" => {-1, 0}, "R" => {1, 0}}

    m =
      IO.read(:all)
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.split/1)
      |> Enum.map(fn [d, n, _] -> {d, n |> String.to_integer()} end)
      |> Enum.reduce({{0, 0}, MapSet.new()}, fn {d, n}, {p, acc} ->
        1..n
        |> Enum.reduce({p, acc}, fn _, {p, acc} ->
          np = p |> P.add(dirs[d])
          {np, acc |> MapSet.put(np)}
        end)
      end)
      |> elem(1)

    (compute(m) |> MapSet.size()) + (m |> MapSet.size())
  end
end

M.solve() |> IO.puts()
