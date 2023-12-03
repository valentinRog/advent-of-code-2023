defmodule M do
  defp first_digit(s) do
    {head, tail} = String.split_at(s, 1)

    case Integer.parse(head) do
      :error -> first_digit(tail)
      _ -> head
    end
  end

  def solve do
    IO.read(:stdio, :all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&(first_digit(&1) <> first_digit(String.reverse(&1))))
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end
end

IO.puts(M.solve())
