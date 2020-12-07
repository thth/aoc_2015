defmodule Nine do
  def part_one(input) do
    distances = parse(input)
    locations =
      distances
      |> Enum.map(fn {{a, b}, _} -> [a, b] end)
      |> List.flatten()
      |> Enum.uniq()

    locations
    |> permutations()
    |> Enum.map(&(total_distance(&1, distances)))
    |> Enum.min()
  end

  def part_two(input) do
    distances = parse(input)
    locations =
      distances
      |> Enum.map(fn {{a, b}, _} -> [a, b] end)
      |> List.flatten()
      |> Enum.uniq()

    locations
    |> permutations()
    |> Enum.map(&(total_distance(&1, distances)))
    |> Enum.max()
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.into(%{}, fn line ->
      [_, a, b, distance] = Regex.run(~r/(\w+) to (\w+) = (\d+)/, line)
      key = if a < b, do: {a, b}, else: {b, a}
      {key, String.to_integer(distance)}
    end)
  end

  defp permutations([]), do: [[]]
  defp permutations(list) do
    for h <- list, t <- permutations(list -- [h]), do: [h | t]
  end

  defp total_distance(path, distance_map, distance \\ 0)
  defp total_distance([_], _, distance), do: distance
  defp total_distance([a, b | rest], distance_map, distance) do
    key = if a < b, do: {a, b}, else: {b, a}
    total_distance([b | rest], distance_map, distance + distance_map[key])
  end
end

input = File.read!("input/09.txt")

input
|> Nine.part_one()
|> IO.inspect()

input
|> Nine.part_two()
|> IO.inspect()
