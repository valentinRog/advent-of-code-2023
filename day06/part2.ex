defmodule M do
  def solve do
    [t, d] =
      IO.read(:all)
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn s ->
        s |> String.split() |> Stream.drop(1) |> Enum.join() |> String.to_integer()
      end)

    0..t
    |> Stream.map(&{&1, &1 * (t - &1)})
    |> Enum.count(fn {_, dd} -> dd > d end)
  end
end

IO.puts(M.solve())
