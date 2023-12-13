defmodule AoC do
  def solve(file_path) do
    with {:ok, content} <- File.read(file_path) do
      data =
        content
        |> String.trim()
        |> String.split("\n")
        |> Enum.map(&String.trim(&1))
        |> Enum.with_index()
        |> Enum.flat_map(fn {s, y} ->
          s
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.map(fn {c, x} ->
            {{x, y}, c}
          end)
        end)
        |> Enum.reduce(%{}, fn {k, v}, acc -> acc |> Map.put(k, v) end)

      dirs = %{
        "n" => {0, -1},
        "s" => {0, 1},
        "w" => {-1, 0},
        "e" => {1, 0}
      }

      pipes = %{
        "F" => %{dirs["n"] => dirs["e"], dirs["w"] => dirs["s"]},
        "-" => %{dirs["e"] => dirs["e"], dirs["w"] => dirs["w"]},
        "7" => %{dirs["e"] => dirs["s"], dirs["n"] => dirs["w"]},
        "|" => %{dirs["s"] => dirs["s"], dirs["n"] => dirs["n"]},
        "J" => %{dirs["s"] => dirs["w"], dirs["e"] => dirs["n"]},
        "L" => %{dirs["s"] => dirs["e"], dirs["w"] => dirs["n"]}
      }

      p0 = data |> Enum.find(fn {_, v} -> v == "S" end) |> elem(0)

      d0 =
        "nswe"
        |> String.graphemes()
        |> Enum.find(fn c ->
          {dx, dy} = dirs[c]
          {x, y} = p0
          {nx, ny} = {x + dx, y + dy}
          {dx, dy} = {dx * -1, dy * -1}

          case data[{nx, ny}] do
            nil -> false
            c -> pipes[c] |> Map.values() |> Enum.member?({dx, dy})
          end
        end)

      loop =
        Stream.iterate(0, &(&1 + 1))
        |> Enum.reduce_while({p0, dirs[d0], MapSet.new()}, fn _, {{px, py}, {dx, dy}, loop} ->
          {px, py} = {px + dx, py + dy}

          loop = loop |> MapSet.put({px, py})

          cond do
            {px, py} == p0 ->
              {:halt, loop}

            true ->
              {dx, dy} = pipes[data[{px, py}]][{dx, dy}]
              {:cont, {{px, py}, {dx, dy}, loop}}
          end
        end)

      {w, h} = data |> Map.keys() |> Enum.max(fn {lx, ly}, {rx, ry} -> lx + ly > rx + ry end)

      0..h
      |> Enum.map(fn y ->
        0..w
        |> Enum.reduce({0, false, "|"}, fn x, {n, b, prev} ->
          {b, prev} =
            case {loop |> MapSet.member?({x, y}), prev, data[{x, y}]} do
              {false, _, _} -> {b, prev}
              {_, _, "-"} -> {b, prev}
              {_, _, "|"} -> {not b, "|"}
              {_, "L", "7"} -> {not b, "7"}
              {_, "F", "J"} -> {not b, "J"}
              {_, _, c} -> {b, c}
            end

          case {MapSet.member?(loop, {x, y}), b} do
            {false, true} -> {n + 1, b, prev}
            _ -> {n, b, prev}
          end
        end)
      end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.sum()
    end
  end
end

IO.inspect(AoC.solve("input.txt"), label: "Result")
