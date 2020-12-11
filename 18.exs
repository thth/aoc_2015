defmodule Eighteen do
  def part_one(input) do
    input
    |> parse()
    |> Stream.iterate(&step/1)
    |> Enum.at(100)
    |> Enum.count(fn {_, lit?} -> lit? end)
  end

  def part_two(input) do
    map = parse(input)
    {max_x, max_y} = map |> Map.keys() |> Enum.max()

    [{0, 0}, {max_x, 0}, {0, max_y}, {max_x, max_y}]
    |> Enum.reduce(map, fn corner, acc -> %{acc | corner => true} end)
    |> Stream.iterate(&(step_with_stuck_corners(&1, {max_x, max_y})))
    |> Enum.at(100)
    # |> draw()
    |> Enum.count(fn {_, lit?} -> lit? end)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"#", x}, inner_acc -> Map.put(inner_acc, {x, y}, true)
        {".", x}, inner_acc -> Map.put(inner_acc, {x, y}, false)
      end)
    end)
  end

  defp step(map), do: for light <- map, into: %{}, do: step_light(light, map)

  defp step_light({light, lit?}, map) do
    adj_lit = count_adj(light, map)
    cond do
      lit? and adj_lit == 2 or adj_lit == 3 -> {light, true}
      not lit? and adj_lit == 3 -> {light, true}
      true -> {light, false}
    end
  end

  defp count_adj({x, y}, map) do
    (for a <- (x-1)..(x+1), b <- (y-1)..(y+1), not (a == x and b == y), do: {a, b})
    |> Enum.count(&Map.get(map, &1))
  end

  defp step_with_stuck_corners(map, {max_x, max_y}) do
    for {{x, y}, _} = light <- map,
        into: %{} do
      if {x, y} in [{0, 0}, {max_x, 0}, {0, max_y}, {max_x, max_y}] do
        {{x, y}, true}
      else
        step_light(light, map)
      end
    end
  end

  def draw(map) do
    {max_x, max_y} = map |> Map.keys() |> Enum.max()
    for y <- 0..max_y,
        x <- 0..max_x do
      if map[{x, y}] do
        IO.write("#")
      else
        IO.write(".")
      end
      if x == max_x, do: IO.write("\n")
    end
    IO.write("\n")

    map
  end
end

input = File.read!("input/18.txt")

input
|> Eighteen.part_one()
|> IO.inspect()

input
|> Eighteen.part_two()
|> IO.inspect()
