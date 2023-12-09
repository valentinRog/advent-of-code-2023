defmodule M do
  def solve do
    [path, m] = IO.read(:stdio, :all) |> String.trim() |> String.split("\n\n")
    path = path |> String.graphemes() |> Stream.cycle()

    m =
      m
      |> (fn s -> "=(,)" |> String.split("") |> Enum.reduce(s, &String.replace(&2, &1, "")) end).()
      |> String.split("\n")
      |> Stream.map(&String.split/1)
      |> Enum.reduce(%{}, fn [k, l, r], acc -> acc |> Map.put(k, %{"L" => l, "R" => r}) end)

    path
    |> Enum.reduce_while({"AAA", 0}, fn d, {p, n} ->
      case p do
        "ZZZ" -> {:halt, n}
        _ -> {:cont, {m[p][d], n + 1}}
      end
    end)
  end
end

IO.puts(M.solve())
