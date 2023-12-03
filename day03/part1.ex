defmodule M do
  def isdigit(s) do
    "0123456789" |> String.contains?(s)
  end

  def isSymbol(s) do
    not ("0123456789." |> String.contains?(s))
  end

  def group([], l) do
    l
  end

  def group(data, l) do
    data = data |> Enum.drop_while(fn {c, _} -> not isdigit(c) end)

    ll =
      data
      |> Enum.take_while(fn {c, _} -> c |> isdigit() end)
      |> Enum.reduce([], fn {_, i}, acc -> acc ++ [i] end)

    data = data |> Enum.drop(ll |> length)
    group(data, l ++ [ll])
  end

  def valid([i | tail], raw, {w, h}) do
    {x, y} = {rem(i, w), div(i, w)}

    [
      {x, y - 1},
      {x + 1, y - 1},
      {x + 1, y},
      {x + 1, y + 1},
      {x, y + 1},
      {x - 1, y + 1},
      {x - 1, y},
      {x - 1, y - 1}
    ]
    |> Enum.filter(fn {x, y} -> x >= 0 and y >= 0 and x < w and y < h end)
    |> Enum.any?(fn {x, y} -> isSymbol(String.at(raw, y * w + x)) end) or
      valid(tail, raw, {w, h})
  end

  def valid([], _, _) do
    false
  end

  def solve do
    raw =
      IO.read(:stdio, :all)
      |> String.trim()

    w = raw |> String.graphemes() |> Enum.find_index(&(&1 == "\n"))
    w = w + 1
    raw = raw |> String.replace("\n", ".")
    data = raw |> String.graphemes() |> Enum.with_index()

    h = raw |> String.length() |> div(w)

    group(data, [])
    |> Enum.filter(&valid(&1, raw, {w, h}))
    |> Enum.map(fn l -> l |> Enum.reduce("", fn i, acc -> acc <> String.at(raw, i) end) end)

    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end
end

IO.inspect(M.solve())
