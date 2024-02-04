defmodule M do
  defp digit?(c), do: "0123456789" |> String.contains?(c)

  defp parse_instructions([s], acc), do: acc ++ [s]

  defp parse_instructions([h | t], acc) do
    acc =
      acc ++
        [
          {
            String.at(h, 0),
            String.at(h, 1),
            h
            |> String.graphemes()
            |> Enum.filter(&digit?/1)
            |> Enum.join()
            |> String.to_integer(),
            h |> String.split(":") |> Enum.at(-1)
          }
        ]

    parse_instructions(t, acc)
  end

  defp parse_instructions(l), do: l |> parse_instructions([])

  defp compute("A", _, workflows) do
    workflows |> Map.values() |> Enum.map(fn {x0, x1} -> x1 - x0 + 1 end) |> Enum.product()
  end

  defp compute("R", _, _), do: 0

  defp compute([s], workflows, ratings) do
    compute(workflows[s], workflows, ratings)
  end

  defp compute([{k, c, n, s} | t], workflows, ratings) do
    {x0, x1} = ratings[k]

    {r_valid, r_invalid} =
      %{
        ">" => {{n + 1, x1}, {x0, n}},
        "<" => {{x0, n - 1}, {n, x1}}
      }[c]

    compute(workflows[s], workflows, ratings |> Map.put(k, r_valid)) +
      compute(t, workflows, ratings |> Map.put(k, r_invalid))
  end

  defp compute(workflows) do
    compute(["in"], workflows, %{
      "x" => {1, 4000},
      "m" => {1, 4000},
      "a" => {1, 4000},
      "s" => {1, 4000}
    })
  end

  def solve do
    IO.read(:all)
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(&String.split/1)
    |> Enum.at(0)
    |> Enum.map(fn s ->
      "{,}"
      |> String.graphemes()
      |> Enum.reduce(s, fn c, s -> s |> String.replace(c, " ") end)
      |> String.split()
    end)
    |> Enum.map(fn [h | t] -> {h, t |> parse_instructions()} end)
    |> Enum.reduce(%{}, fn {k, v}, m -> m |> Map.put(k, v) end)
    |> Map.put("A", "A")
    |> Map.put("R", "R")
    |> compute()
  end
end

M.solve() |> IO.puts()
