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
    workflows |> Map.values() |> Enum.sum()
  end

  defp compute("R", _, _), do: 0

  defp compute([s], workflows, ratings) do
    compute(workflows[s], workflows, ratings)
  end

  defp compute([{k, c, n, s} | t], workflows, ratings) do
    case %{">" => ratings[k] > n, "<" => ratings[k] < n}[c] do
      true -> compute(workflows[s], workflows, ratings)
      false -> compute(t, workflows, ratings)
    end
  end

  defp compute(workflows, ratings), do: compute(["in"], workflows, ratings)

  def solve do
    [workflows, ratings] =
      IO.read(:all) |> String.trim() |> String.split("\n\n") |> Enum.map(&String.split/1)

    workflows =
      workflows
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

    ratings
    |> Enum.map(fn s ->
      s
      |> String.replace("{", "")
      |> String.replace("}", "")
      |> String.split(",")
      |> Enum.map(fn s -> s |> String.split("=") end)
      |> Enum.map(fn [k, v] -> {k, v |> String.to_integer()} end)
      |> Enum.reduce(%{}, fn {k, v}, m -> m |> Map.put(k, v) end)
    end)
    |> Enum.map(&compute(workflows, &1))
    |> Enum.sum()
  end
end

M.solve() |> IO.puts()
