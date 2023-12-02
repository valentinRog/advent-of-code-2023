defmodule M do
  defp first_digit(s, m) do
    case Enum.find(Map.keys(m), &String.starts_with?(s, &1)) do
      nil ->
        {head, tail} = String.split_at(s, 1)

        case Integer.parse(head) do
          :error -> first_digit(tail, m)
          _ -> head
        end

      k ->
        Map.get(m, k)
    end
  end

  def solve do
    m = %{
      "one" => "1",
      "two" => "2",
      "three" => "3",
      "four" => "4",
      "five" => "5",
      "six" => "6",
      "seven" => "7",
      "eight" => "8",
      "nine" => "9"
    }

    mr = Enum.reduce(m, %{}, fn {k, v}, acc -> Map.put(acc, String.reverse(k), v) end)

    IO.read(:stdio, :all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&(first_digit(&1, m) <> first_digit(String.reverse(&1), mr)))
    |> Enum.map(fn x ->
      {x, ""} = Integer.parse(x)
      x
    end)
    |> Enum.sum()
  end
end

IO.puts(M.solve())
