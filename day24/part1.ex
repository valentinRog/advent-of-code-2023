defmodule M do
  defp intersection([_, [vx1, vy1]], [_, [vx2, vy2]]) when vy1 / vx1 == vy2 / vx2 do
    nil
  end

  defp intersection([[x1, y1], [vx1, vy1]], [[x2, y2], [vx2, vy2]]) do
    m1 = vy1 / vx1
    m2 = vy2 / vx2
    x = (m1 * x1 - y1 - m2 * x2 + y2) / (m1 - m2)
    y = m1 * (x - x1) + y1

    case (x - x1) / vx1 < 0 or (x - x2) / vx2 < 0 or (y - y1) / vy1 < 0 or (y - y2) / vy2 < 0 do
      true -> nil
      _ -> {x, y}
    end
  end

  defp compute(data), do: compute(data, 0)

  defp compute([], acc), do: acc

  defp compute([h | t], acc) do
    in_bound = fn n -> n >= 200_000_000_000_000 and n <= 400_000_000_000_000 end

    n =
      t
      |> Enum.map(fn e -> intersection(h, e) end)
      |> Enum.filter(&(&1 != nil))
      |> Enum.filter(fn {x, y} -> in_bound.(x) and in_bound.(y) end)
      |> Enum.count()

    compute(t, acc + n)
  end

  def solve do
    IO.read(:all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn s ->
      s
      |> String.split("@")
      |> Enum.map(fn s ->
        s
        |> String.split(",")
        |> Enum.take(2)
        |> Enum.map(&String.trim/1)
        |> Enum.map(&String.to_integer/1)
      end)
    end)
    |> compute()
  end
end

M.solve() |> IO.puts()
