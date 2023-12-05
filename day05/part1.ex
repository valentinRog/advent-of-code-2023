defmodule M do
  defp location([], n), do: n

  defp location([head | tail], n) do
    n =
      case head |> Enum.find(fn [_, s, l] -> n in s..(s + l - 1) end) do
        nil -> n
        [d, s, _] -> d + n - s
      end

    location(tail, n)
  end

  def solve do
    data =
      IO.read(:stdio, :all)
      |> String.trim()
      |> String.split("\n\n")

    maps =
      data
      |> Enum.drop(1)
      |> Enum.map(fn s ->
        s
        |> String.split("\n")
        |> Enum.drop(1)
        |> Enum.map(fn s -> s |> String.split() |> Enum.map(&String.to_integer/1) end)
      end)

    data
    |> Enum.at(0)
    |> String.split()
    |> Stream.drop(1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&location(maps, &1))
    |> Enum.min()
  end
end

IO.inspect(M.solve())
