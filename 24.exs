defmodule TwentyFour do
  def part_one(input) do
    input
    |> parse()
    |> find_first_groups()
    |> Enum.map(&quantum_entanglement/1)
    |> Enum.min()
  end

  def part_two(input) do
    input
    |> parse()
    |> find_first_groups_with_trunk()
    |> Enum.map(&quantum_entanglement/1)
    |> Enum.min()
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  defp find_first_groups(list) do
    target_weight = div(Enum.sum(list), 3)
    do_find(list, target_weight)
  end

  defp find_first_groups_with_trunk(list) do
    target_weight = div(Enum.sum(list), 4)
    do_find(list, target_weight)
  end

  # make hash of sum of weights from half-length permutations,
  # find other half-length permutations with which both add to target weight
  # (but filter out permutation pairs which share elements)
  defp do_find(list, target, len \\ 1)
  defp do_find(list, target, 1),
    do: if target in list, do: [target], else: do_find(list, target, 2)
  defp do_find(list, target, len) do
    hash_size = div(len, 2)
    hash =
      permute(list, hash_size)
      |> Enum.map(fn subset -> {Enum.sum(subset), subset} end)
      |> Enum.into(%{})

    found =
      permute(list, len - hash_size)
      |> Enum.reduce([], fn subset, acc ->
        case Map.get(hash, target - Enum.sum(subset)) do
          nil -> acc
          hash_subset ->
            intersections =
              MapSet.intersection(MapSet.new(subset), MapSet.new(hash_subset))
              |> MapSet.size()
            if intersections == 0 do
              [subset ++ hash_subset | acc]
            else
              acc
            end
        end
      end)

    case found do
      [] -> do_find(list, target, len + 1)
      found_list -> found_list
    end
  end

  def permute([], _), do: [[]]
  def permute(_, 0), do: [[]]
  def permute(list, n) do
    for x <- list, y <- permute(list -- [x], n - 1), do: [x | y]
  end

  defp quantum_entanglement(list) do
    Enum.reduce(list, &*/2)
  end
end

input = File.read!("input/24.txt")

input
|> TwentyFour.part_one()
|> IO.inspect()

input
|> TwentyFour.part_two()
|> IO.inspect()
