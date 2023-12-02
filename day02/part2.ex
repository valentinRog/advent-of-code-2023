defmodule M do
  defp score(["Game", _ | tail], m) do
    score(tail, m)
  end

  defp score([a, b | tail], m) do
    {n, ""} = Integer.parse(a)
    m = Map.put(m, b, max(n, Map.get(m, b, 0)))
    score(tail, m)
  end

  defp score([], m) do
    Map.values(m) |> Enum.product()
  end

  def solve do
    IO.read(:stdio, :all)
    |> String.trim()
    |> (fn s -> ":,;" |> String.split("") |> Enum.reduce(s, &String.replace(&2, &1, "")) end).()
    |> String.split("\n")
    |> Enum.map(&String.split(&1))
    |> Enum.map(&score(&1, %{}))
    |> Enum.sum()
  end
end

IO.puts(M.solve())
