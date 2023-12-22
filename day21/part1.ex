defmodule M do
  defp traverse(p, 64, _) do
    Agent.update(:res, fn res -> res |> MapSet.put(p) end)
  end

  defp traverse({x, y}, steps, data) do
    unless Agent.get(:cache, fn cache -> cache |> MapSet.member?({{x, y}, steps}) end) do
      Agent.update(:cache, fn cache -> cache |> MapSet.put({{x, y}, steps}) end)

      [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
      |> Stream.map(fn {dx, dy} -> {x + dx, y + dy} end)
      |> Stream.filter(fn p -> data[p] == "." end)
      |> Enum.each(&traverse(&1, steps + 1, data))
    end
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

    p0 = data |> Enum.find(fn {_, v} -> v == "S" end) |> elem(0)
    data = data |> Map.replace(p0, ".")
    Agent.start_link(fn -> MapSet.new() end, name: :res)
    Agent.start_link(fn -> MapSet.new() end, name: :cache)
    traverse(p0, 0, data)
    Agent.get(:res, &MapSet.size/1)
  end
end

IO.puts(M.solve())
