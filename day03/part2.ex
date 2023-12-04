defmodule M do
  defp digit?(s), do: "0123456789" |> String.contains?(s)

  defp group([], l, []), do: l
  defp group([], l, ll), do: l ++ [ll]

  defp group([{{x, y}, c} | tail], l, ll) do
    cond do
      not digit?(c) and ll == [] -> group(tail, l, ll)
      not digit?(c) -> group(tail, l ++ [ll], [])
      true -> group(tail, l, ll ++ [{{x, y}, c}])
    end
  end

  defp valid?([], _), do: false

  defp valid?([{{x, y}, _} | tail], symbols) do
    [
      {x, y - 1},
      {x + 1, y - 1},
      {x + 1, y},
      {x + 1, y + 1},
      {x, y + 1},
      {x - 1, y + 1},
      {x - 1, y},
      {x - 1, y - 1}
    ]
    |> Enum.any?(fn p -> symbols |> MapSet.member?(p) end) or valid?(tail, symbols)
  end

  defp symbol_pos([{{x, y}, _} | tail], symbols) do
    p =
      [
        {x, y - 1},
        {x + 1, y - 1},
        {x + 1, y},
        {x + 1, y + 1},
        {x, y + 1},
        {x - 1, y + 1},
        {x - 1, y},
        {x - 1, y - 1}
      ]
      |> Enum.find(fn p -> symbols |> MapSet.member?(p) end)

    case p do
      nil -> symbol_pos(tail, symbols)
      _ -> p
    end
  end

  def solve do
    data =
      IO.read(:stdio, :all)
      |> String.trim()
      |> String.replace("\n", ".\n")
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.flat_map(fn {s, y} ->
        s
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {c, x} -> {{x, y}, c} end)
      end)

    symbols =
      data
      |> Enum.filter(fn {_, v} -> v == "*" end)
      |> Enum.reduce(MapSet.new(), fn {k, _}, acc -> acc |> MapSet.put(k) end)

    group(data, [], [])
    |> Enum.filter(&valid?(&1, symbols))
    |> Enum.map(&{&1, symbol_pos(&1, symbols)})
    |> Enum.map(fn {e, p} ->
      {e |> Enum.map(fn {_, c} -> c end) |> Enum.join() |> String.to_integer(), p}
    end)
    |> Enum.group_by(&elem(&1, 1))
    |> Map.values()
    |> Enum.filter(&(&1 |> length == 2))
    |> Enum.map(fn [{n1, _}, {n2, _}] -> n1 * n2 end)
    |> Enum.sum()
  end
end

IO.inspect(M.solve())
