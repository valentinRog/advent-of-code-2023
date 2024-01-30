defmodule M do
  defp hash(s) do
    s |> String.to_charlist() |> Enum.reduce(0, fn c, n -> rem((n + c) * 17, 256) end)
  end

  defp compute([], m), do: m

  defp compute([{s, n} | t], m) do
    v =
      m[hash(s)]
      |> Enum.map(fn {ss, nn} ->
        case ss do
          ^s -> {ss, n}
          _ -> {ss, nn}
        end
      end)

    v =
      case v |> Enum.map(&elem(&1, 0)) |> Enum.member?(s) do
        false -> v ++ [{s, n}]
        _ -> v
      end

    compute(t, m |> Map.put(hash(s), v))
  end

  defp compute([s | t], m) do
    compute(t, m |> Map.put(hash(s), m[hash(s)] |> Enum.filter(&(elem(&1, 0) != s))))
  end

  defp compute(l) do
    compute(l, 0..255 |> Enum.reduce(%{}, fn k, acc -> acc |> Map.put(k, []) end))
  end

  defp power(m, s) do
    i = m[hash(s)] |> Enum.find_index(&(elem(&1, 0) == s))
    (1 + hash(s)) * (i + 1) * (m[hash(s)] |> Enum.at(i) |> elem(1))
  end

  def solve do
    m =
      IO.read(:all)
      |> String.trim()
      |> String.replace("-", " ")
      |> String.replace("=", " ")
      |> String.split(",")
      |> Enum.map(&String.split/1)
      |> Enum.map(fn e ->
        case e do
          [s, n] -> {s, n |> String.to_integer()}
          [s] -> s
        end
      end)
      |> compute()

    m
    |> Map.values()
    |> Enum.flat_map(& &1)
    |> Enum.reduce([], fn {s, _}, acc -> acc ++ [s] end)
    |> Enum.map(&power(m, &1))
    |> Enum.sum()
  end
end

M.solve() |> IO.puts()
