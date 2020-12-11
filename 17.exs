defmodule Seventeen do
  @eggnog 150

  def part_one(input) do
    input
    |> parse()
    |> count(@eggnog)
  end

  def part_two(input) do
    input
    |> parse()
    |> map_counts(@eggnog)
    |> Enum.filter(fn {k, v} -> v != 0 end)
    |> Enum.sort()
    |> hd()
    |> elem(1)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  defp count(list, target), do: do_count(Enum.sort(list), target)

  defp do_count([], _), do: 0
  defp do_count([head | _rest], target) when head > target, do: 0
  defp do_count([target | rest], target), do: 1 + do_count(rest, target)
  defp do_count([head | rest], target) do
    do_count(rest, target - head) + do_count(rest, target)
  end

  defp map_counts(list, target), do: do_counts(Enum.sort(list), target, 0)

  defp do_counts([], _, used), do: Map.put(%{}, used, 0)
  defp do_counts([head | _rest], target, used) when head > target, do: Map.put(%{}, used, 0)
  defp do_counts([target | rest], target, used) do
    not_using = do_counts(rest, target, used)
    Map.merge(not_using, Map.put(%{}, used, 1), fn _k, v1, v2 ->
      v1 + v2
    end)
  end
  defp do_counts([head | rest], target, used) do
    using = do_counts(rest, target - head, used + 1)
    not_using = do_counts(rest, target, used)
    Map.merge(using, not_using, fn _k, v1, v2 ->
      v1 + v2
    end)
  end
end

input = File.read!("input/17.txt")

input
|> Seventeen.part_one()
|> IO.inspect()

input
|> Seventeen.part_two()
|> IO.inspect()
