defmodule M do
  defp score({m, rocks}) do
    my = m |> Map.keys() |> Stream.map(fn {_, y} -> y end) |> Enum.max()
    rocks |> Enum.reduce(0, fn {_, y}, n -> n + my - y + 1 end)
  end

  defp roll({m, rocks}) do
    rocks
    |> Enum.reduce(MapSet.new(), fn {x, y}, acc ->
      case m[{x, y - 1}] do
        v when v == nil or v == "#" ->
          acc |> MapSet.put({x, y})

        _ ->
          case rocks |> MapSet.member?({x, y - 1}) do
            true -> acc |> MapSet.put({x, y})
            false -> acc |> MapSet.put({x, y - 1})
          end
      end
    end)
  end

  defp compute({m, rocks}, prev_score) do
    rocks = {m, rocks} |> roll()

    case({m, rocks} |> score()) do
      ^prev_score -> prev_score
      n -> {m, rocks} |> compute(n)
    end
  end

  defp compute({m, rocks}), do: compute({m, rocks}, nil)

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
