defmodule M do
  def solve() do
    data =
      IO.read(:all)
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.trim(&1))
      |> Enum.with_index()
      |> Enum.flat_map(fn {s, y} ->
        s
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {c, _} -> c != "." end)
        |> Enum.map(fn {c, x} -> {{x, y}, c} end)
      end)
      |> Enum.reduce(%{}, fn {k, v}, acc -> acc |> Map.put(k, v) end)

    dirs = %{
      n: {0, -1},
      s: {0, 1},
      w: {-1, 0},
      e: {1, 0}
    }

    pipes = %{
      "F" => %{dirs.n => dirs.e, dirs.w => dirs.s},
      "-" => %{dirs.e => dirs.e, dirs.w => dirs.w},
      "7" => %{dirs.e => dirs.s, dirs.n => dirs.w},
      "|" => %{dirs.s => dirs.s, dirs.n => dirs.n},
      "J" => %{dirs.s => dirs.w, dirs.e => dirs.n},
      "L" => %{dirs.s => dirs.e, dirs.w => dirs.n}
    }

    {x0, y0} = data |> Enum.find(fn {_, v} -> v == "S" end) |> elem(0)

    d0 =
      dirs
      |> Map.keys()
      |> Enum.find(fn c ->
        {dx, dy} = dirs[c]

        case data[{x0 + dx, y0 + dy}] do
          nil -> false
          c -> pipes[c] |> Map.values() |> Enum.member?({dx * -1, dy * -1})
        end
      end)

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({{x0, y0}, dirs[d0]}, fn i, {{px, py}, {dx, dy}} ->
      case {px + dx, py + dy} do
        {^x0, ^y0} -> {:halt, i}
        {px, py} -> {:cont, {{px, py}, pipes[data[{px, py}]][{dx, dy}]}}
      end
    end)
    |> (fn n -> div(n, 2) + rem(n, 2) end).()
  end
end

IO.puts(M.solve())
