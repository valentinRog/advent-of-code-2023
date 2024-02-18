defmodule M do
  defp make_graph(data) do
    data
    |> Enum.reduce(%{}, fn {x, y}, acc ->
      v =
        [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]
        |> Enum.reduce(%{}, fn {dx, dy}, acc ->
          case data |> MapSet.member?({x + dx, y + dy}) do
            true -> acc |> Map.put({x + dx, y + dy}, 1)
            false -> acc
          end
        end)

      acc |> Map.put({x, y}, v)
    end)
  end

  defp contract_edge(graph, p) do
    [p1, p2] = graph[p] |> Map.keys()
    l = path_len(graph, [p1, p, p2])

    graph =
      graph
      |> Map.delete(p)
      |> Map.put(p1, graph[p1] |> Map.delete(p))
      |> Map.put(p2, graph[p2] |> Map.delete(p))

    graph
    |> Map.put(p1, graph[p1] |> Map.put(p2, l))
    |> Map.put(p2, graph[p2] |> Map.put(p1, l))
  end

  defp contract_graph(graph) do
    case(graph |> Map.keys() |> Enum.find(fn p -> graph[p] |> map_size == 2 end)) do
      nil -> graph
      p -> graph |> contract_edge(p) |> contract_graph()
    end
  end

  defp path_len(graph, path) do
    path
    |> Enum.drop(1)
    |> Enum.reduce({0, path |> Enum.at(0)}, fn pp, {n, p} -> {n + graph[p][pp], pp} end)
    |> elem(0)
  end

  defp dfs(graph, p, path, p1) when p == p1 do
    graph |> path_len(path)
  end

  defp dfs(graph, p, path, p1) do
    graph[p]
    |> Map.keys()
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
      |> (fn s ->
            ">v^<"
            |> String.graphemes()
            |> Enum.reduce(s, fn c, s -> s |> String.replace(c, ".") end)
          end).()
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {s, y} ->
        s
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {c, x} -> {{x, y}, c} end)
      end)
      |> Enum.filter(fn {_, c} -> c == "." end)
      |> Enum.reduce(MapSet.new(), fn {p, _}, acc -> acc |> MapSet.put(p) end)
      |> make_graph()
      |> contract_graph()

    p0 = graph |> Map.keys() |> Enum.min()
    p1 = graph |> Map.keys() |> Enum.max()

    graph |> dfs(p0, [p0], p1)
  end
end

M.solve() |> IO.puts()
