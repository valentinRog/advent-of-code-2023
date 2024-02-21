defmodule M do
  defp e1([px0, py0, _pz0, vx0, vy0, _vz0], [pxi, pyi, _pzi, vxi, vyi, _vzi]) do
    [
      vy0 - vyi,
      vxi - vx0,
      0,
      pyi - py0,
      px0 - pxi,
      0,
      px0 * vy0 - py0 * vx0 - pxi * vyi + pyi * vxi
    ]
  end

  defp e2([px0, _py0, pz0, vx0, _vy0, vz0], [pxi, _pyi, pzi, vxi, _vyi, vzi]) do
    [
      vz0 - vzi,
      0,
      vxi - vx0,
      pzi - pz0,
      0,
      px0 - pxi,
      px0 * vz0 - pz0 * vx0 - pxi * vzi + pzi * vxi
    ]
  end

  defp submatrix(m, {i, j}) do
    m
    |> Map.keys()
    |> Enum.reduce(%{}, fn {ii, jj}, acc ->
      k =
        case {ii, jj} do
          {^i, _} ->
            nil

          {_, ^j} ->
            nil

          _ ->
            ni =
              case ii > i do
                true -> ii - 1
                _ -> ii
              end

            nj =
              case jj > j do
                true -> jj - 1
                _ -> jj
              end

            {ni, nj}
        end

      case k do
        nil -> acc
        _ -> acc |> Map.put(k, m[{ii, jj}])
      end
    end)
  end

  defp make_matrix(m) do
    m
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, i} ->
      row |> Enum.with_index() |> Enum.map(fn {n, j} -> {{i, j}, n} end)
    end)
    |> Enum.reduce(%{}, fn {k, v}, acc -> acc |> Map.put(k, v) end)
  end

  defp mi(m) do
    m |> Map.keys() |> Enum.max() |> elem(0)
  end

  defp det(m) when map_size(m) == 1 do
    m[{0, 0}]
  end

  defp det(m) do
    0..mi(m)
    |> Enum.reduce(0, fn i, acc ->
      sign =
        case rem(i, 2) do
          0 -> 1
          1 -> -1
        end

      acc + sign * m[{i, 0}] * det(submatrix(m, {i, 0}))
    end)
  end

  defp replace_col(m, l, j) do
    l |> Enum.with_index() |> Enum.reduce(m, fn {n, i}, acc -> acc |> Map.put({i, j}, n) end)
  end

  defp cramer(a, b) do
    d = det(a)
    0..2 |> Enum.map(fn j -> div(a |> replace_col(b, j) |> det(), d) end)
  end

  def solve do
    data =
      IO.read(:all)
      |> String.trim()
      |> String.replace(",", "")
      |> String.replace("@", "")
      |> String.split("\n")
      |> Enum.map(fn s -> s |> String.split() |> Enum.map(&String.to_integer/1) end)

    r0 = data |> Enum.at(1)
    rs = data |> Enum.drop(1) |> Enum.take_random(3)
    coeff = rs |> Enum.flat_map(fn r -> [e1(r0, r), e2(r0, r)] end)
    a = coeff |> Enum.map(&List.delete_at(&1, -1)) |> make_matrix()
    b = coeff |> Enum.map(&Enum.at(&1, -1))
    cramer(a, b) |> Enum.sum()
  end
end

M.solve() |> IO.puts()
