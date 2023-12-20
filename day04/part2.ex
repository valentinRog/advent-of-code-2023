defmodule M do
  use Agent

  defp score(m, i) do
    case Agent.get(:cache, & &1)[i] do
      nil ->
        (1 +
           case m |> Map.get(i, 0) do
             0 -> 0
             n -> (i + 1)..(i + n) |> Stream.map(&score(m, &1)) |> Enum.sum()
           end)
        |> (fn n -> Agent.update(:cache, fn cache -> cache |> Map.put(i, n) end) end).()

        score(m, i)

      n ->
        n
    end
  end

  def solve do
    m =
      IO.read(:stdio, :all)
      |> String.trim()
      |> String.split("\n")
      |> Enum.flat_map(&(String.split(&1, ":") |> Enum.drop(1)))
      |> Enum.map(fn s ->
        String.split(s, "|")
        |> Enum.map(
          &(String.split(&1)
            |> Enum.reduce(MapSet.new(), fn v, acc -> acc |> MapSet.put(v) end))
        )
      end)
      |> Enum.map(fn [s1, s2] -> MapSet.intersection(s1, s2) |> MapSet.size() end)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {v, k}, acc -> acc |> Map.put(k, v) end)

    Agent.start_link(fn -> %{} end, name: :cache)
    m |> Map.keys() |> Stream.map(&score(m, &1)) |> Enum.sum()
  end
end

IO.puts(M.solve())
