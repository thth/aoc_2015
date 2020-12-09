defmodule Fifteen do
  @max_tsps 100

  def part_one(input) do
    stats = parse(input)

    initial_combination = List.duplicate(0, length(stats) - 1) ++ [@max_tsps]
    final_combination   = [@max_tsps] ++ List.duplicate(0, length(stats) - 1)

    Stream.unfold(initial_combination, fn
      nil -> nil
      ^final_combination -> {final_combination, nil}
      combination -> {combination, next_combination(combination)}
    end)
    |> Enum.max_by(&(score(&1, stats)))
    |> score(stats)
  end

  def part_two(input) do
    stats = parse(input)

    initial_combination = List.duplicate(0, length(stats) - 1) ++ [@max_tsps]
    final_combination   = [@max_tsps] ++ List.duplicate(0, length(stats) - 1)

    Stream.unfold(initial_combination, fn
      nil -> nil
      ^final_combination -> {final_combination, nil}
      combination ->
        case calories(combination, stats) do
          500 -> {combination, next_combination(combination)}
          _not_500 -> {nil, next_combination(combination)}
        end
    end)
    |> Enum.max_by(fn
      nil -> 0
      combination -> score(combination, stats)
    end)
    |> score(stats)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(fn line ->
      Regex.scan(~r/(\-*\d+)/, line, capture: :all_but_first)
      |> Enum.map(fn [str] -> String.to_integer(str) end)
    end)
  end

  defp next_combination([head | rest]), do: next_combination([], head, rest, head)
  defp next_combination(stays_same, maybe_inc, [check | rest], sum) do
    if check + sum == @max_tsps do
      stays_same ++ [maybe_inc + 1] ++ List.duplicate(0, length(rest)) ++ [check - 1]
    else
      next_combination(stays_same ++ [maybe_inc], check, rest, sum + check)
    end
  end

  defp score(combination, stats) do
    combination
    |> Enum.with_index()
    |> Enum.map(fn {multiple, i} ->
      stats
      |> Enum.at(i)
      |> Enum.slice(0..-2)
      |> Enum.map(&(multiple * &1))
    end)
    |> List.zip()
    |> Enum.map(&Tuple.to_list(&1))
    |> Enum.reduce_while(1, fn points, acc ->
      case Enum.sum(points) do
        sum when sum < 0 -> {:halt, 0}
        sum -> {:cont, acc * sum}
      end
    end)
  end

  defp calories(combination, stats) do
    combination
    |> Enum.with_index()
    |> Enum.reduce(0, fn {multiple, i}, acc ->
      stats
      |> Enum.at(i)
      |> Enum.at(-1)
      |> Kernel.*(multiple)
      |> Kernel.+(acc)
    end)
  end
end

input = File.read!("input/15.txt")

input
|> Fifteen.part_one()
|> IO.inspect()

input
|> Fifteen.part_two()
|> IO.inspect()
