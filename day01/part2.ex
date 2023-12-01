defmodule M do
  def first_digit(s) do
    [head | tail] = String.graphemes(s)

    case Integer.parse(head) do
      {x, ""} -> x
      _ -> first_digit(Enum.join(tail))
    end
  end

  def place_after("", acc) do
    acc
  end

  def place_after(s, acc) do
    w =
      cond do
        String.starts_with?(s, "one") -> "1"
        String.starts_with?(s, "two") -> "2"
        String.starts_with?(s, "three") -> "3"
        String.starts_with?(s, "four") -> "4"
        String.starts_with?(s, "five") -> "5"
        String.starts_with?(s, "six") -> "6"
        String.starts_with?(s, "seven") -> "7"
        String.starts_with?(s, "eight") -> "8"
        String.starts_with?(s, "nine") -> "9"
        true -> ""
      end

    [head | tail] = String.graphemes(s)
    place_after(Enum.join(tail), acc <> w <> head)
  end

  def solve do
    IO.read(:stdio, :all)
    |> String.trim()
    |> String.split()
    |> Enum.map(&place_after(&1, ""))
    |> Enum.map(&"#{first_digit(&1)}#{first_digit(String.reverse(&1))}")
    |> Enum.map(fn x ->
      {x, ""} = Integer.parse(x)
      x
    end)
    |> Enum.sum()
  end
end

IO.puts(M.solve())
