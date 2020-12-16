defmodule Twenty do
  def part_one(input) do
    target = parse(input)

    Stream.iterate({0, 0}, fn {last_step, _last_presents} ->
      {last_step + 1, presents(last_step + 1)}
    end)
    |> Enum.find_value(fn {step, n_presents} ->
      if n_presents >= target, do: step, else: nil
    end)
  end

  def part_two(input) do
    target = parse(input)

    Stream.iterate({0, 0, nil}, fn {last_step, _last_presents, acc} ->
      {n_presents, new_acc} = presents_two(last_step + 1, acc)
      {last_step + 1, n_presents, new_acc}
    end)
    |> Enum.find_value(fn {step, n_presents, _acc} ->
      if n_presents >= target, do: step, else: nil
    end)
  end

  defp parse(text) do
    text
    |> String.to_integer()
  end

  defp presents(step) do
    step |> factors() |> Enum.sum() |> Kernel.*(10)
  end

  defp presents_two(step, nil), do: presents_two(step, %{})
  defp presents_two(step, past_acc) do
    {kept_factors, new_acc} =
      step
      |> factors()
      |> Enum.reduce({[], past_acc}, fn factor, {keep, acc} ->
        case Map.get(acc, factor, 0) do
          50 -> {keep, acc}
          n -> {[factor | keep], Map.put(acc, factor, n + 1)}
        end
      end)
    n_presents = kept_factors |> Enum.sum() |> Kernel.*(11)
    {n_presents, new_acc}
  end

  # factors of an integer; transcribed from rosettacode
  defp factors(n, i \\ 1, list \\ [])
  defp factors(n, i, list) when n < i * i, do: list
  defp factors(n, i, list) when n == i * i, do: [i | list]
  defp factors(n, i, list) when rem(n, i) == 0, do: factors(n, i + 1, [i, div(n, i) | list])
  defp factors(n, i, list), do: factors(n, i + 1, list)
end

input = File.read!("input/20.txt")

input
|> Twenty.part_one()
|> IO.inspect()

input
|> Twenty.part_two()
|> IO.inspect()
