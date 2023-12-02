defmodule M do
  defp first_digit(s) do
    {head, tail} = String.split_at(s, 1)

    case Integer.parse(head) do
      {_, ""} -> head
      _ -> first_digit(tail)
    end
  end

  def solve do
    IO.read(:stdio, :all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&(first_digit(&1) <> first_digit(String.reverse(&1))))
    |> Enum.map(fn x ->
      {x, ""} = Integer.parse(x)
      x
    end)
    |> Enum.sum()
  end
end

IO.puts(M.solve())
