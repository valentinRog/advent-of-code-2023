defmodule M do
  def solve do
    IO.read(:stdio, :all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn s ->
      s |> String.split() |> Stream.drop(1) |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
    |> Enum.map(fn {t, d} ->
      0..t
      |> Enum.map(&{&1, &1 * (t - &1)})
      |> Enum.count(fn {_, dd} -> dd > d end)
    end)
    |> Enum.product()
  end
end

IO.puts(M.solve())
