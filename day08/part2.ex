defmodule M do
  defp path_len(m, path, p) do
    path
    |> Enum.reduce_while({p, 0}, fn d, {p, n} ->
      cond do
        p |> String.ends_with?("Z") -> {:halt, n}
        true -> {:cont, {m[p][d], n + 1}}
      end
    end)
  end

  def solve do
    [path, m] = IO.read(:all) |> String.trim() |> String.split("\n\n")
    path = path |> String.graphemes() |> Stream.cycle()

    m =
      m
      |> (fn s -> "=(,)" |> String.split("") |> Enum.reduce(s, &String.replace(&2, &1, "")) end).()
      |> String.split("\n")
      |> Stream.map(&String.split/1)
      |> Enum.reduce(%{}, fn [k, l, r], acc -> acc |> Map.put(k, %{"L" => l, "R" => r}) end)

    m
    |> Map.keys()
    |> Enum.filter(&(&1 |> String.ends_with?("A")))
    |> Enum.map(&path_len(m, path, &1))
    |> Enum.reduce(1, fn n, acc ->
      div(n * acc, Integer.gcd(n, acc))
    end)
  end
end

IO.puts(M.solve())
