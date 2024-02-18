defmodule M do
  defp can_go?(data, {x, y}, {dx, dy}) do
    case {data[{x + dx, y + dy}], {dx, dy}} do
      {".", _} -> true
      {"^", {0, -1}} -> true
      {"v", {0, 1}} -> true
      {"<", {-1, 0}} -> true
      {">", {1, 0}} -> true
      _ -> false
    end
  end

  defp make_graph(data) do
    data
    |> Map.keys()
    |> Enum.reduce(%{}, fn {x, y}, acc ->
      v =
        [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]
        |> Enum.reduce([], fn {dx, dy}, acc ->
          case data |> can_go?({x, y}, {dx, dy}) do
            true -> acc ++ [{x + dx, y + dy}]
            false -> acc
          end
        end)

      acc |> Map.put({x, y}, v)
    end)
  end

  defp dfs(_, p, path, p1) when p == p1 do
    path |> length()
  end

  defp dfs(graph, p, path, p1) do
    graph[p]
    |> Enum.reduce(0, fn pp, acc ->
      case path |> Enum.member?(pp) do
        true -> acc
        false -> max(acc, dfs(graph, pp, path ++ [pp], p1))
      end
    end)
  end

  def solve do
    graph =
      IO.read(:all)
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {s, y} ->
        s
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {c, x} -> {{x, y}, c} end)
      end)
      |> Enum.reduce(%{}, fn {k, v}, acc -> acc |> Map.put(k, v) end)
      |> make_graph()

    {x0, y0} = graph |> Map.keys() |> Enum.min()
    {xf, yf} = graph |> Map.keys() |> Enum.max()

    graph |> dfs({x0 + 1, y0}, [], {xf - 1, yf})
  end
end

M.solve() |> IO.puts()
