defmodule M do
  defp valid?(s, ns) do
    s
    |> String.split(".", trim: true)
    |> Enum.map(&String.length/1) == ns
  end

  defp possible?(s, ns) do
    l = s |> String.split(".", trim: true) |> Enum.map(&String.length/1)

    case l |> length do
      len when len > 1 -> l |> Enum.take(len - 1) == ns |> Enum.take(len - 1)
      _ -> true
    end
  end

  defp combinaisons([], acc, _), do: acc

  defp combinaisons([h | t], acc, ns) do
    acc =
      acc
      |> Enum.flat_map(fn s ->
        cond do
          not possible?(s, ns) -> []
          h == "?" -> [s <> ".", s <> "#"]
          true -> [s <> h]
        end
      end)

    combinaisons(t, acc, ns)
  end

  def solve do
    IO.read(:all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [s, ns] -> {s, ns |> String.split(",") |> Enum.map(&String.to_integer/1)} end)
    |> Enum.map(fn {s, ns} ->
      combinaisons(s |> String.graphemes(), [""], ns)
      |> Enum.filter(&valid?(&1, ns))
      |> Enum.count()
    end)
    |> Enum.sum()
  end
end

M.solve() |> IO.puts()
