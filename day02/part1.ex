defmodule M do
  defp ok([n, c]) do
    case c do
      "red" -> n <= 12
      "green" -> n <= 13
      "blue" -> n <= 14
    end
  end

  defp valid(l) do
    Enum.drop(l, 2)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [n, c] -> [String.to_integer(n), c] end)
    |> Enum.all?(&ok/1)
  end

  def solve do
    IO.read(:stdio, :all)
    |> String.trim()
    |> (fn s -> ":,;" |> String.split("") |> Enum.reduce(s, &String.replace(&2, &1, "")) end).()
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.filter(&valid/1)
    |> Enum.map(fn [_, id | _] -> String.to_integer(id) end)
    |> Enum.sum()
  end
end

IO.puts(M.solve())
