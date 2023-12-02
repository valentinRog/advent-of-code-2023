defmodule M do
  defp valid(["Game", _ | tail]) do
    valid(tail)
  end

  defp valid([a, b | tail]) do
    {n, ""} = Integer.parse(a)

    max =
      case b do
        "red" -> 12
        "green" -> 13
        "blue" -> 14
      end

    n <= max and valid(tail)
  end

  defp valid([]) do
    true
  end

  def solve do
    IO.read(:stdio, :all)
    |> String.trim()
    |> (fn s -> ":,;" |> String.split("") |> Enum.reduce(s, &String.replace(&2, &1, "")) end).()
    |> String.split("\n")
    |> Enum.map(&String.split(&1))
    |> Enum.filter(&valid(&1))
    |> Enum.map(fn [_, id | _] ->
      {id, ""} = Integer.parse(id)
      id
    end)
    |> Enum.sum()
  end
end

IO.puts(M.solve())
