defmodule M do
  use Agent

  defp get_from_cache(i) do
    Agent.get(__MODULE__, & &1)[i]
  end

  defp add_to_cache(i, n) do
    Agent.update(__MODULE__, fn cache -> cache |> Map.put(i, n) end)
  end

  defp score(m, i) do
    case get_from_cache(i) do
      nil ->
        add_to_cache(
          i,
          1 +
            case m |> Map.get(i, 0) do
              0 -> 0
              n -> (i + 1)..(i + n) |> Stream.map(&score(m, &1)) |> Enum.sum()
            end
        )
        score(m, i)
      n -> n
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

    Agent.start_link(fn -> %{} end, name: __MODULE__)
    m |> Map.keys() |> Stream.map(&score(m, &1)) |> Enum.sum()
  end
end

IO.puts(M.solve())
