defmodule M do
  defp disintegratable?(data, l) do
    data |> Enum.filter(&(&1 != l)) |> (fn data -> data |> stable?(make_set(data)) end).()
  end

  defp stable?(data, hs) do
    data |> Enum.all?(fn l -> not brick_can_fall?(l, hs) end)
  end

  defp brick_can_fall?(l, hs) do
    l
    |> Enum.map(fn {x, y, z} -> {x, y, z - 1} end)
    |> Enum.all?(fn p ->
      (not (hs |> MapSet.member?(p)) or l |> Enum.member?(p)) and p |> elem(2) > 0
    end)
  end

  defp fall_brick(l, hs) do
    case brick_can_fall?(l, hs) do
      true -> l |> Enum.map(fn {x, y, z} -> {x, y, z - 1} end)
      false -> l
    end
  end

  defp fall(data) do
    hs = data |> make_set()
    data |> Enum.map(fn l -> fall_brick(l, hs) end)
  end

  defp fall_max(data) do
    case data |> fall() do
      ^data -> data
      data -> fall_max(data)
    end
  end

  defp make_brick([[x0, y0, z0], [x1, y1, z1]]) do
    for x <- x0..x1, y <- y0..y1, z <- z0..z1, do: {x, y, z}
  end

  defp make_set(data) do
    data
    |> Enum.flat_map(& &1)
    |> Enum.reduce(MapSet.new(), fn p, acc -> acc |> MapSet.put(p) end)
  end

  def solve do
    data =
      IO.read(:all)
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn s ->
        s
        |> String.split("~")
        |> Enum.map(fn s -> s |> String.split(",") |> Enum.map(&String.to_integer/1) end)
      end)
      |> Enum.map(&make_brick/1)
      |> fall_max()

    data |> Enum.filter(fn l -> disintegratable?(data, l) end) |> Enum.count()
  end
end

M.solve() |> IO.puts()
