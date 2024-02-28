defmodule M do
  defp parse_instruction(s) do
    [cmp, dst] = s |> String.split(":")
    [k, c | n] = cmp |> String.graphemes()
    {k, c, n |> Enum.join() |> String.to_integer(), dst}
  end

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
      |> Enum.map(fn [h | t] ->
        {h, (Enum.drop(t, -1) |> Enum.map(&parse_instruction/1)) ++ Enum.take(t, -1)}
      end)
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
