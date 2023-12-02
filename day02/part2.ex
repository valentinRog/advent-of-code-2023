defmodule M do
  defp valid(["Game", _ | tail], m) do
    valid(tail, m)
  end

  defp valid([a, b | tail], m) do
    {n, ""} = Integer.parse(a)
    m = Map.put(m, b, max(n, Map.get(m, b, 0)))
    valid(tail, m)
  end

  defp valid([], m) do
    Map.values(m) |> Enum.product()
  end

  def solve do
    IO.read(:stdio, :all)
    |> String.trim()
    |> String.replace(":", "")
    |> String.replace(";", "")
    |> String.replace(",", "")
    |> String.split("\n")
    |> Enum.map(&String.split(&1))
    |> Enum.map(&valid(&1, %{}))
    |> Enum.sum()
  end
end

IO.puts(M.solve())
