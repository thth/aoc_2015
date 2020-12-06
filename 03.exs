defmodule Three do
  def part_one(input) do
    input
    |> parse()
    |> deliver_presents()
    |> Enum.count()
  end

  def part_two(input) do
    {santa_directions, robot_directions} =
      input
      |> parse()
      |> Enum.with_index()
      |> Enum.reduce({[], []}, fn
        {dir, i}, {santa_dirs, robot_dirs} when rem(i, 2) == 0 ->
          {santa_dirs ++ [dir], robot_dirs}
        {dir, _i}, {santa_dirs, robot_dirs} ->
          {santa_dirs, robot_dirs ++ [dir]}
      end)

    santa_houses = santa_directions |> deliver_presents() |> Map.keys() |> MapSet.new()
    robot_houses = robot_directions |> deliver_presents() |> Map.keys() |> MapSet.new()

    MapSet.union(santa_houses, robot_houses)
    |> MapSet.size()
  end

  defp parse(text) do
    text
    |> String.graphemes()
  end

  defp deliver_presents(directions) do
    directions
    |> Enum.reduce({{0, 0}, %{{0, 0} => 1}}, fn dir, {{x, y}, acc} ->
      new_pos =
        case dir do
          "^" -> {x, y + 1}
          "v" -> {x, y - 1}
          "<" -> {x - 1, y}
          ">" -> {x + 1, y}
        end
      {new_pos, Map.update(acc, new_pos, 1, &(&1 + 1))}
    end)
    |> elem(1)
  end
end

input = File.read!("input/03.txt")

input
|> Three.part_one()
|> IO.inspect()

input
|> Three.part_two()
|> IO.inspect()
