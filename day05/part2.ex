defmodule M do
  defp seed?(seeds, n) do
    seeds |> Enum.any?(fn [s, l] -> n in s..(s + l - 1) end)
  end

  defp seed([], n, skip), do: {n, skip}

  defp seed([head | tail], n, skip) do
    bound_skip = fn skip, new_skip ->
      case skip do
        nil -> new_skip
        _ -> min(skip, new_skip)
      end
    end

    {n, skip} =
      case head |> Enum.find(fn [s, _, l] -> n in s..(s + l - 1) end) do
        nil ->
          {n,
           skip
           |> bound_skip.(
             Stream.filter(head, fn [s, _, _] -> s > n end)
             |> Stream.map(fn [s, _, _] -> s - n end)
             |> Enum.min(fn -> 1 end)
           )}

        [s, d, l] ->
          {d + n - s, skip |> bound_skip.(l - (n - s))}
      end

    seed(tail, n, skip)
  end

  defp compute(maps, seeds, i) do
    {n, skip} = seed(maps, i, nil)

    skip =
      case seeds |> Enum.find(fn [s, _] -> n < s and s < n + skip end) do
        nil -> skip
        [s, _] -> s - n
      end

    case seed?(seeds, n) do
      true -> i
      _ -> compute(maps, seeds, i + skip)
    end
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
      |> Enum.reverse()

    seeds =
      data
      |> Enum.at(0)
      |> String.split()
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2)

    compute(maps, seeds, 0)
  end
end

IO.puts(M.solve())
