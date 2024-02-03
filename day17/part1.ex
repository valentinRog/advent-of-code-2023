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
