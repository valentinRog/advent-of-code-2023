defmodule M do
  defp parse_instruction(s) do
    [cmp, dst] = s |> String.split(":")
    [k, c | n] = cmp |> String.graphemes()
    {k, c, n |> Enum.join() |> String.to_integer(), dst}
  end

  defp compute("A", _, workflows) do
    workflows |> Map.values() |> Enum.map(fn {x0, x1} -> x1 - x0 + 1 end) |> Enum.product()
  end

  defp compute("R", _, _), do: 0

  defp compute([s], workflows, ratings), do: compute(workflows[s], workflows, ratings)

  defp compute([{k, c, n, s} | t], workflows, ratings) do
    {x0, x1} = ratings[k]

    {r_valid, r_invalid} =
      case c do
        ">" -> {{n + 1, x1}, {x0, n}}
        "<" -> {{x0, n - 1}, {n, x1}}
      end

    compute(workflows[s], workflows, ratings |> Map.put(k, r_valid)) +
      compute(t, workflows, ratings |> Map.put(k, r_invalid))
  end

  defp compute(workflows) do
    r0 = {1, 4000}
    compute(["in"], workflows, %{"x" => r0, "m" => r0, "a" => r0, "s" => r0})
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
    |> Enum.map(fn [h | t] ->
      {h, (Enum.drop(t, -1) |> Enum.map(&parse_instruction/1)) ++ Enum.take(t, -1)}
    end)
    |> Enum.reduce(%{}, fn {k, v}, m -> m |> Map.put(k, v) end)
    |> Map.put("A", "A")
    |> Map.put("R", "R")
    |> compute()
  end
end

M.solve() |> IO.puts()
