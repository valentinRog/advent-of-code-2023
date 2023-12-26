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

  defp path(_, _, [], _, _), do: nil

  defp path(dest, conn, [head | tail], seen, restrictions) do
    case head |> Enum.at(-1) do
      ^dest ->
        head

      p ->
        tail =
          conn[p]
          |> Enum.reduce(tail, fn p, acc ->
            case seen |> MapSet.member?(head |> Enum.at(-1)) or
                   (p != dest and restrictions |> MapSet.member?(p)) do
              true -> acc
              _ -> acc ++ [head ++ [p]]
            end
          end)

        path(dest, conn, tail, seen |> MapSet.put(head |> Enum.at(-1)), restrictions)
    end
  end

  defp path(src, dest, conn, restrictions) do
    path(dest, conn, [[src]], MapSet.new(), restrictions)
  end

  defp more_than_3_paths?(_, _, _, _, n) when n > 3, do: true

  defp more_than_3_paths?(src, dest, conn, restrictions, n) do
    case path(src, dest, conn, restrictions) do
      nil ->
        false

      res ->
        more_than_3_paths?(src, dest, conn, restrictions |> MapSet.union(MapSet.new(res)), n + 1)
    end
  end

  defp more_than_3_paths?(src, dest, conn) do
    more_than_3_paths?(src, dest, conn, MapSet.new(), 0)
  end

  defp all_paths(src, dest, conn, restrictions, acc) do
    case path(src, dest, conn, restrictions) do
      nil ->
        acc

      path ->
        all_paths(src, dest, conn, restrictions |> MapSet.union(MapSet.new(path)), acc ++ [path])
    end
  end

  defp all_paths(src, dest, conn), do: all_paths(src, dest, conn, MapSet.new(), [])

  defp combinaisons([], acc), do: acc

  defp combinaisons([head | tail], []) do
    combinaisons(tail, head |> Enum.map(&[&1]))
  end

  defp combinaisons([head | tail], acc) do
    acc = acc |> Enum.flat_map(fn l -> head |> Enum.map(fn x -> l ++ [x] end) end)
    combinaisons(tail, acc)
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

    [src, dest] =
      data
      |> Map.keys()
      |> Enum.flat_map(fn k -> data |> Map.keys() |> Enum.map(&[&1, k]) end)
      |> Enum.find(fn [src, dest] -> not more_than_3_paths?(src, dest, data) end)

    all_paths(src, dest, data)
    |> Enum.map(fn l -> l |> Enum.chunk_every(2, 1, :discard) end)
    |> combinaisons([])
    |> Stream.map(fn duos -> data |> groups_size(duos) end)
    |> Enum.find(&(length(&1) == 2))
    |> Enum.product()
  end
end

IO.puts(M.solve())
