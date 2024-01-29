defmodule M do
  defp dfs([], ns, acc, tmp) do
    acc = (acc ++ [tmp]) |> Enum.filter(&(&1 != 0))
    acc = acc |> Enum.filter(&(&1 != 0))

    case acc == ns do
      true -> 1
      _ -> 0
    end
  end

  defp dfs(s, ns, acc, tmp) do
    acc = acc |> Enum.filter(&(&1 != 0))

    if(acc != ns |> Enum.take(acc |> length)) do
      0
    else
      [c | s] = s

      case c do
        "?" -> dfs(s, ns, acc, tmp + 1) + dfs(s, ns, acc ++ [tmp], 0)
        "." -> dfs(s, ns, acc ++ [tmp], 0)
        "#" -> dfs(s, ns, acc, tmp + 1)
      end
    end
  end

  defp dfs(s, ns), do: dfs(s, ns, [], 0)

  def solve do
    IO.read(:all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [s, ns] -> {s, ns |> String.split(",") |> Enum.map(&String.to_integer/1)} end)
    |> Enum.map(fn {s, ns} -> dfs(s |> String.graphemes(), ns) end)
    |> Enum.sum()
  end
end

M.solve() |> IO.puts()
