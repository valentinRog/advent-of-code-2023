defmodule MinHeap do
  defp fix_push(h, i) do
    p = div(i, 2) + rem(i, 2) - 1

    case p < 0 or h[p] <= h[i] do
      true -> h
      _ -> h |> Map.put(i, h[p]) |> Map.put(p, h[i]) |> fix_push(p)
    end
  end

  def push(h, v) do
    h |> Map.put(h |> map_size(), v) |> fix_push(h |> map_size())
  end

  defp fix_pop(h, i) do
    f = fn i, ii ->
      case ii < map_size(h) and h[ii] < h[i] do
        true -> ii
        _ -> i
      end
    end

    case i |> f.(2 * i + 1) |> f.(2 * i + 2) do
      ^i -> h
      ii -> h |> Map.put(i, h[ii]) |> Map.put(ii, h[i]) |> fix_pop(ii)
    end
  end

  def pop(h) do
    case h |> map_size() do
      n when n <= 1 ->
        {h[0], %{}}

      _ ->
        {h[0],
         h
         |> Map.delete(map_size(h) - 1)
         |> Map.put(0, h[map_size(h) - 1])
         |> fix_pop(0)}
    end
  end
end

defmodule P do
  def add({px1, py1}, {px2, py2}), do: {px1 + px2, py1 + py2}

  def prod({px, py}, k), do: {px * k, py * k}

  def module({px, py}), do: abs(px) + abs(py)

  def dir({0, 0}), do: {0, 0}

  def dir(p), do: p |> prod(1 / module(p))
end

defmodule M do
  defp new_ds({0, 0}, d), do: d

  defp new_ds(ds, d) do
    case ds |> P.dir() == d do
      true -> ds |> P.add(d)
      _ -> d
    end
  end

  defp dijkstra_compute_d(m, {q, dists}, p, ds, d) do
    np = p |> P.add(d)
    cost = dists[{p, ds}] + m[np]
    ds = ds |> new_ds(d)

    cond do
      P.module(ds) > 10 ->
        {q, dists}

      dists |> Map.has_key?({np, ds}) and dists[{np, ds}] <= cost ->
        {q, dists}

      true ->
        {q |> MinHeap.push({cost, {np, ds}}),
         dists |> Map.put({np, ds}, cost) |> Map.put(np, cost)}
    end
  end

  defp dijkstra(m, pf, q, dists) do
    {{_, {p, ds}}, q} = q |> MinHeap.pop()

    {q, dists} =
      [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
      |> Enum.reduce({q, dists}, fn d, {q, dists} ->
        cond do
          not (m |> Map.has_key?(p |> P.add(d))) -> {q, dists}
          ds |> P.dir() == d |> P.prod(-1) -> {q, dists}
          ds |> P.dir() != d and ds |> P.module() < 4 and P.module(ds) > 0 -> {q, dists}
          p |> P.add(d) == pf and ds |> new_ds(d) |> P.module() < 4 -> {q, dists}
          true -> dijkstra_compute_d(m, {q, dists}, p, ds, d)
        end
      end)

    case dists[pf] do
      nil -> dijkstra(m, pf, q, dists)
      cost -> cost
    end
  end

  defp dijkstra(m) do
    k0 = {{0, 0}, {0, 0}}
    dijkstra(m, m |> Map.keys() |> Enum.max(), %{0 => {0, k0}}, %{k0 => 0})
  end

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
      |> Enum.map(fn {c, x} -> {{x, y}, c |> String.to_integer()} end)
    end)
    |> Enum.reduce(%{}, fn {k, v}, acc -> acc |> Map.put(k, v) end)
    |> dijkstra()
  end
end

M.solve() |> IO.puts()
