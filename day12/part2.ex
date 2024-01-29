defmodule M do
  use Agent

  defp serialize(s, ns, acc, tmp) do
    case tmp do
      0 -> {s |> Enum.join(), ns |> Enum.drop(acc |> length)}
      _ -> nil
    end
  end

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
      key = serialize(s, ns, acc, tmp)

      case Agent.get(:cache, & &1[key]) do
        nil ->
          [c | s] = s

          n =
            case c do
              "?" -> dfs(s, ns, acc, tmp + 1) + dfs(s, ns, acc ++ [tmp], 0)
              "." -> dfs(s, ns, acc ++ [tmp], 0)
              "#" -> dfs(s, ns, acc, tmp + 1)
            end

          if not is_nil(key) do
            Agent.update(:cache, &(&1 |> Map.put(key, n)))
          end

          n

        n ->
          n
      end
    end
  end

  defp dfs(s, ns), do: dfs(s, ns, [], 0)

  def solve do
    Agent.start_link(fn -> %{} end, name: :cache)

    IO.read(:all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [s, ns] ->
      {s |> String.graphemes(), ns |> String.split(",") |> Enum.map(&String.to_integer/1)}
    end)
    |> Enum.map(fn {s, ns} ->
      0..3 |> Enum.reduce({s, ns}, fn _, {ss, nns} -> {ss ++ ["?"] ++ s, nns ++ ns} end)
    end)
    |> Enum.map(fn {s, ns} -> dfs(s, ns) end)
    |> Enum.sum()
  end
end

M.solve() |> IO.puts()
