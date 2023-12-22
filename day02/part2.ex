defmodule M do
  defp score([a, b | tail], m) do
    score(tail, m |> Map.put(b, max(String.to_integer(a), m |> Map.get(b, 0))))
  end

  defp score([], m), do: m |> Map.values() |> Enum.product()

  def solve do
    IO.read(:all)
    |> String.trim()
    |> (fn s -> ":,;" |> String.split("") |> Enum.reduce(s, &String.replace(&2, &1, "")) end).()
    |> String.split("\n")
    |> Enum.map(&(String.split(&1) |> Enum.drop(2)))
    |> Enum.map(&score(&1, %{}))
    |> Enum.sum()
  end
end

IO.puts(M.solve())
