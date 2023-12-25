defmodule M do
  defp extract_group(conn, k) do
    v = conn[k] || []
    conn = conn |> Map.delete(k)
    v |> Enum.reduce(conn, fn v, acc -> extract_group(acc, v) end)
  end

  defp extract_group(conn) do
    extract_group(conn, conn |> Enum.at(0) |> elem(0))
  end

  defp disconnect(conn, [k1, k2]) do
    v1 = conn[k1] |> MapSet.delete(k2)
    v2 = conn[k2] |> MapSet.delete(k1)
    conn |> Map.put(k1, v1) |> Map.put(k2, v2)
  end

  defp groups_size(conn, duos, acc) do
    res = extract_group(conn)

    cond do
      res |> map_size() == 0 -> acc ++ [conn |> map_size()]
      true -> groups_size(res, duos, acc ++ [(conn |> map_size()) - (res |> map_size())])
    end
  end

  defp groups_size(conn, duos) do
    conn = duos |> Enum.reduce(conn, fn wires, acc -> disconnect(acc, wires) end)
    groups_size(conn, duos, [])
  end

  def solve do
    data =
      IO.read(:all)
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, ":"))
      |> Enum.map(fn [k, v] -> {k, v |> String.split()} end)
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        insert = fn acc, k, v ->
          v =
            case acc[k] do
              nil -> MapSet.new(v)
              vv -> vv |> MapSet.union(MapSet.new(v))
            end

          acc |> Map.put(k, v)
        end

        acc = acc |> insert.(k, v)
        v |> Enum.reduce(acc, fn kk, acc -> acc |> insert.(kk, [k]) end)
      end)

    duos =
      data
      |> Enum.flat_map(fn {k, v} ->
        v |> Enum.reduce([], fn v, acc -> acc ++ [[k, v] |> Enum.sort()] end)
      end)
      |> Enum.uniq()
  end
end

IO.inspect(M.solve())
