defmodule M do
  defp conn(ins, name) do
    ins |> Map.keys() |> Enum.filter(fn k -> ins[k] |> elem(1) |> Enum.member?(name) end)
  end

  defp update_pulse({hp, lp}, 0), do: {hp, lp + 1}
  defp update_pulse({hp, lp}, 1), do: {hp + 1, lp}

  defp compute({_, pulse, _}, nil, {ff, history}, {hp, lp}) do
    {[], {ff, history}, {hp, lp} |> update_pulse(pulse)}
  end

  defp compute({_, 1, _}, {"%", _}, {ff, history}, {hp, lp}) do
    {[], {ff, history}, {hp + 1, lp}}
  end

  defp compute({_, 0, name}, {"%", l}, {ff, history}, {hp, lp}) do
    ff = ff |> Map.put(name, not ff[name])
    {l |> Enum.map(fn k -> {name, (ff[name] && 1) || 0, k} end), {ff, history}, {hp, lp + 1}}
  end

  defp compute({caller, pulse, name}, {"&", l}, {ff, history}, {hp, lp}) do
    {hp, lp} = {hp, lp} |> update_pulse(pulse)

    history = history |> Map.put(name, history[name] |> Map.put(caller, pulse))

    pulse =
      case history[name] |> Map.values() |> Enum.all?(&(&1 == 1)) do
        true -> 0
        _ -> 1
      end

    {l |> Enum.map(fn k -> {name, pulse, k} end), {ff, history}, {hp, lp}}
  end

  defp simulate(_, [], {ff, history}, {hp, lp}) do
    {{ff, history}, {hp, lp}}
  end

  defp simulate(ins, [{caller, pulse, name} | t], {ff, history}, {hp, lp}) do
    {q, {ff, history}, {hp, lp}} =
      compute({caller, pulse, name}, ins[name], {ff, history}, {hp, lp})

    simulate(ins, t ++ q, {ff, history}, {hp, lp})
  end

  def solve() do
    data =
      IO.read(:all)
      |> String.trim()
      |> String.replace("->", "")
      |> String.replace(",", "")
      |> String.replace("%", "% ")
      |> String.replace("&", "& ")
      |> String.split("\n")
      |> Enum.map(&String.split/1)

    broadcaster = data |> Enum.find(fn [h | _] -> h == "broadcaster" end) |> Enum.drop(1)

    ins =
      data
      |> Enum.filter(fn [h | _] -> h != "broadcaster" end)
      |> Enum.reduce(%{}, fn [type, name | t], acc ->
        acc |> Map.put(name, {type, t})
      end)

    ff =
      ins
      |> Map.keys()
      |> Enum.filter(&(ins[&1] |> elem(0) == "%"))
      |> Enum.reduce(%{}, fn k, acc -> acc |> Map.put(k, false) end)

    history =
      ins
      |> Map.keys()
      |> Enum.filter(&(ins[&1] |> elem(0) == "&"))
      |> Enum.reduce(%{}, fn k, acc ->
        acc |> Map.put(k, conn(ins, k) |> Enum.reduce(%{}, fn k, acc -> acc |> Map.put(k, 0) end))
      end)

    q = broadcaster |> Enum.map(fn k -> {nil, 0, k} end)

    1..1000
    |> Enum.reduce({{ff, history}, {0, 0}}, fn _, {{ff, history}, {hp, lp}} ->
      simulate(ins, q, {ff, history}, {hp, lp + 1})
    end)
    |> elem(1)
    |> Tuple.to_list()
    |> Enum.product()
  end
end

M.solve() |> IO.puts()
