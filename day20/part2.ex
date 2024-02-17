defmodule M do
  defp conn(ins, name) do
    ins |> Map.keys() |> Enum.filter(fn k -> ins[k] |> elem(1) |> Enum.member?(name) end)
  end

  defp compute(_, nil, {ff, history, cycles}, _) do
    {[], {ff, history, cycles}}
  end

  defp compute({_, 1, _}, {"%", _}, {ff, history, cycles}, _) do
    {[], {ff, history, cycles}}
  end

  defp compute({_, 0, name}, {"%", l}, {ff, history, cycles}, _) do
    ff = ff |> Map.put(name, not ff[name])
    {l |> Enum.map(fn k -> {name, (ff[name] && 1) || 0, k} end), {ff, history, cycles}}
  end

  defp compute({caller, pulse, name}, {"&", l}, {ff, history, cycles}, rx_caller) do
    history = history |> Map.put(name, history[name] |> Map.put(caller, pulse))

    pulse =
      case history[name] |> Map.values() |> Enum.all?(&(&1 == 1)) do
        true -> 0
        _ -> 1
      end

    cycles =
      case {name, history[name] |> Map.keys() |> Enum.find(&(history[name][&1] == 1))} do
        {_, nil} -> cycles
        {^rx_caller, k} -> cycles |> Map.put(k, true)
        _ -> cycles
      end

    {l |> Enum.map(fn k -> {name, pulse, k} end), {ff, history, cycles}}
  end

  defp simulate(_, [], {ff, history, cycles}, _) do
    {ff, history, cycles}
  end

  defp simulate(ins, [{caller, pulse, name} | t], {ff, history, cycles}, rx_caller) do
    {q, {ff, history, cycles}} =
      compute({caller, pulse, name}, ins[name], {ff, history, cycles}, rx_caller)

    simulate(ins, t ++ q, {ff, history, cycles}, rx_caller)
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

    rx_caller = ins |> Map.keys() |> Enum.find(&(ins[&1] |> elem(1) == ["rx"]))
    q = broadcaster |> Enum.map(fn k -> {nil, 0, k} end)
    cycles = conn(ins, rx_caller) |> Enum.reduce(%{}, fn k, acc -> acc |> Map.put(k, nil) end)

    1..100_000
    |> Enum.reduce_while({ff, history, cycles}, fn i, {ff, history, cycles} ->
      {ff, history, cycles} = simulate(ins, q, {ff, history, cycles}, rx_caller)

      cycles =
        cycles
        |> Map.keys()
        |> Enum.reduce(%{}, fn k, acc ->
          case cycles[k] do
            true -> acc |> Map.put(k, i)
            v -> acc |> Map.put(k, v)
          end
        end)

      case cycles |> Map.values() |> Enum.all?(&(&1 != nil)) do
        true -> {:halt, cycles}
        false -> {:cont, {ff, history, cycles}}
      end
    end)
    |> Map.values()
    |> Enum.reduce(1, fn n, acc -> div(n * acc, Integer.gcd(n, acc)) end)
  end
end

M.solve() |> IO.puts()
