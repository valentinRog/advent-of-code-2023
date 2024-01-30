defmodule M do
  defp vsym?(_, _, []), do: true

  defp vsym?(axe, m, [{x, y} | t]) do
    cond do
      m[{2 * axe - x + 1, y}] |> is_nil -> vsym?(axe, m, t)
      m[{x, y}] == m[{2 * axe - x + 1, y}] -> vsym?(axe, m, t)
      true -> false
    end
  end

  defp vsym?(axe, m) do
    l = m |> Map.keys() |> Enum.filter(fn {x, _} -> x <= axe end)
    vsym?(axe, m, l)
  end

  defp rotate(m, mx) do
    m
    |> Map.keys()
    |> Enum.reduce(%{}, fn {x, y}, acc -> acc |> Map.put({y, mx - x}, m[{x, y}]) end)
  end

  defp col_on_left(m) do
    mx = m |> Map.keys() |> Enum.map(fn {x, _} -> x end) |> Enum.max()

    case 0..(mx - 1) |> Enum.find(&vsym?(&1, m)) do
      nil -> 100 * col_on_left(m |> rotate(mx))
      axe -> axe + 1
    end
  end

  def solve do
    IO.read(:all)
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(fn s ->
      s
      |> String.split("\n")
      |> Enum.map(&String.trim(&1))
      |> Enum.with_index()
      |> Enum.flat_map(fn {s, y} ->
        s
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {c, x} -> {{x, y}, c} end)
      end)
      |> Enum.reduce(%{}, fn {k, v}, acc -> acc |> Map.put(k, v) end)
    end)
    |> Enum.map(&col_on_left/1)
    |> Enum.sum()
  end
end

M.solve() |> IO.puts()
