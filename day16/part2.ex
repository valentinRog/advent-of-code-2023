defmodule M do
  defp traverse({x, y}, {dx, dy}, data, pipes) do
    unless Agent.get(:cache, fn cache -> cache[{x, y}] == {dx, dy} end) or is_nil(data[{x, y}]) do
      Agent.update(:cache, fn cache -> cache |> Map.put({x, y}, {dx, dy}) end)

      case pipes[data[{x, y}]][{dx, dy}] do
        nil -> traverse({x + dx, y + dy}, {dx, dy}, data, pipes)
        l -> l |> Enum.each(fn {dx, dy} -> traverse({x + dx, y + dy}, {dx, dy}, data, pipes) end)
      end
    end
  end

  defp compute({x, y}, {dx, dy}, data, pipes) do
    Agent.update(:cache, fn _ -> %{} end)
    traverse({x, y}, {dx, dy}, data, pipes)
    Agent.get(:cache, &map_size/1)
  end

  def solve() do
    data =
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
      |> Enum.reduce(%{}, fn {k, v}, acc -> acc |> Map.put(k, v) end)

    dirs = %{
      n: {0, -1},
      s: {0, 1},
      w: {-1, 0},
      e: {1, 0}
    }

    pipes = %{
      "|" => %{dirs.e => [dirs.n, dirs.s], dirs.w => [dirs.n, dirs.s]},
      "-" => %{dirs.n => [dirs.w, dirs.e], dirs.s => [dirs.w, dirs.e]},
      "\\" => %{
        dirs.n => [dirs.w],
        dirs.s => [dirs.e],
        dirs.w => [dirs.n],
        dirs.e => [dirs.s]
      },
      "/" => %{
        dirs.n => [dirs.e],
        dirs.s => [dirs.w],
        dirs.w => [dirs.s],
        dirs.e => [dirs.n]
      },
      "." => %{}
    }

    Agent.start_link(fn -> %{} end, name: :cache)

    mx = data |> Map.keys() |> Stream.map(&elem(&1, 0)) |> Enum.max()
    my = data |> Map.keys() |> Stream.map(&elem(&1, 1)) |> Enum.max()

    0..my
    |> Stream.flat_map(fn y -> 0..mx |> Enum.map(fn x -> {x, y} end) end)
    |> Stream.filter(fn {x, y} -> x == 0 or x == mx or y == 0 or y == my end)
    |> Stream.map(fn {x, y} ->
      dirs
      |> Map.values()
      |> Stream.map(fn {dx, dy} -> compute({x, y}, {dx, dy}, data, pipes) end)
      |> Enum.max()
    end)
    |> Enum.max()
  end
end

IO.puts(M.solve())
