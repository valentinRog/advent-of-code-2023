defmodule M do
  defp score({m, rocks}) do
    my = m |> Map.keys() |> Stream.map(fn {_, y} -> y end) |> Enum.max()
    rocks |> Enum.reduce(0, fn {_, y}, n -> n + my - y + 1 end)
  end

  defp roll({m, rocks}, {dx, dy}) do
    rocks
    |> Enum.reduce(MapSet.new(), fn {x, y}, acc ->
      case m[{x + dx, y + dy}] do
        v when v == nil or v == "#" ->
          acc |> MapSet.put({x, y})

        _ ->
          case rocks |> MapSet.member?({x + dx, y + dy}) do
            true -> acc |> MapSet.put({x, y})
            false -> acc |> MapSet.put({x + dx, y + dy})
          end
      end
    end)
  end

  defp roll_max({m, rocks}, d), do: {m, rocks} |> roll_max(d, nil)

  defp roll_max({m, rocks}, d, prev) do
    rocks = {m, rocks} |> roll(d)

    case rocks == prev do
      true -> rocks
      false -> {m, rocks} |> roll_max(d, rocks)
    end
  end

  defp cycle({m, rocks}) do
    [{0, -1}, {-1, 0}, {0, 1}, {1, 0}]
    |> Enum.reduce(rocks, fn d, rocks -> {m, rocks} |> roll_max(d) end)
  end

  @n_cyles 1_000_000_000

  defp compute({m, rocks}, @n_cyles), do: {m, rocks} |> score()

  defp compute({m, rocks}, k) do
    rocks = {m, rocks} |> cycle()
    {m, rocks} |> compute(k + 1)
  end

  defp compute({m, rocks}, k, cache) do
    rocks = {m, rocks} |> cycle()

    case cache[rocks] do
      nil -> {m, rocks} |> compute(k + 1, cache |> Map.put(rocks, k))
      k0 -> {m, rocks} |> compute(@n_cyles - rem(@n_cyles - k, k - k0))
    end
  end

  defp compute({m, rocks}), do: compute({m, rocks}, 1, %{})

  def solve do
    IO.read(:all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim(&1))
    |> Enum.with_index()
    |> Enum.flat_map(fn {s, y} ->
      s
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {c, x} -> {{x, y}, c} end)
    end)
    |> Enum.reduce({%{}, MapSet.new()}, fn {k, v}, {m, rocks} ->
      case v do
        "O" -> {m |> Map.put(k, "."), rocks |> MapSet.put(k)}
        _ -> {m |> Map.put(k, v), rocks}
      end
    end)
    |> compute()
  end
end

M.solve() |> IO.puts()
