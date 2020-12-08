defmodule Thirteen do
  def part_one(input) do
    happiness_map = parse(input)
    [person | rest] = get_people(happiness_map)
    possible_arrangements =
      rest
      |> permutations()
      |> Enum.map(&([person | &1]))
 
    possible_arrangements
    |> Enum.map(&(calculate_total_happiness(&1, happiness_map)))
    |> Enum.map(&Enum.sum/1)
    |> Enum.max()
  end

  def part_two(input) do
    happiness_map = parse(input)
    others = get_people(happiness_map)
    possible_arrangements =
      others
      |> permutations()
      |> Enum.map(&(["Me" | &1]))

    possible_arrangements
    |> Enum.map(&(calculate_total_happiness(&1, happiness_map)))
    |> Enum.map(&Enum.sum/1)
    |> Enum.max()
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.reduce(%{}, fn line, acc ->
      regex = ~r/^(\w+) would (\w+) (\d+).+ (\w+)\./
      [person, mood, how_happy, neighbor] = Regex.run(regex, line, capture: :all_but_first)
      happiness =
        case mood do
          "gain" -> String.to_integer(how_happy)
          "lose" -> -String.to_integer(how_happy)
        end
      Map.update(acc, person, %{neighbor => happiness}, &Map.put(&1, neighbor, happiness))
    end)
  end

  defp get_people(happiness_map) do
    {person, others_map} = Enum.at(happiness_map, 0)
    [person | Map.keys(others_map)]
  end

  defp permutations([]), do: [[]]
  defp permutations(list) do
    for h <- list, t <- permutations(list -- [h]), do: [h | t]
  end

  defp calculate_total_happiness(arrangement, happiness_map) do
    arrangement
    |> Stream.cycle()
    |> Stream.chunk_every(3, 1)
    |> Enum.take(length(arrangement))
    |> Enum.map(fn [n1, person, n2] ->
      calculate_happiness(person, n1, n2, happiness_map)
    end)
  end

  defp calculate_happiness(person, neighbor1, neighbor2, happiness_map) do
    (happiness_map[person][neighbor1] || 0) + (happiness_map[person][neighbor2] || 0)
  end
end

input = File.read!("input/13.txt")

input
|> Thirteen.part_one()
|> IO.inspect()

input
|> Thirteen.part_two()
|> IO.inspect()
