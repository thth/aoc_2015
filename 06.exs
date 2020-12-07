defmodule Six do
  @greyscale " .:-=+*#%@" |> String.graphemes()

  def part_one(input) do
    grid = MapSet.new()
    instructions = parse(input)

    grid
    |> run_instructions_on_grid(instructions)
    |> MapSet.size()
  end

  def part_two(input) do
    better_grid = %{}
    instructions = parse(input)

    better_grid
    |> run_instructions_on_grid(instructions)
    |> Enum.reduce(0, fn {_coords, brightness}, acc -> acc + brightness end)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(fn line ->
      regex = ~r/^(.+) (\d+),(\d+) through (\d+),(\d+)$/
      [cmd, x1, y1, x2, y2] = Regex.run(regex, line, capture: :all_but_first)

      {
        cmd,
        {String.to_integer(x1), String.to_integer(y1)},
        {String.to_integer(x2), String.to_integer(y2)},
      }
    end)
  end

  defp run_instructions_on_grid(grid, instructions),
    do: Enum.reduce(instructions, grid, &run_instruction_on_grid/2)

  defp run_instruction_on_grid({cmd, {x1, y1}, {x2, y2}}, grid) do
    lights = for x <- x1..x2, y <- y1..y2, do: {x, y}
    Enum.reduce(lights, grid, &change_light_on_grid(cmd, &1, &2))
  end

  defp change_light_on_grid("toggle", light, grid) when is_struct(grid, MapSet) do
    if MapSet.member?(grid, light) do
      MapSet.delete(grid, light)
    else
      MapSet.put(grid, light)
    end
  end
  defp change_light_on_grid("turn on", light, grid) when is_struct(grid, MapSet),
    do: MapSet.put(grid, light)
  defp change_light_on_grid("turn off", light, grid) when is_struct(grid, MapSet),
    do: MapSet.delete(grid, light)

  defp change_light_on_grid("toggle", light, grid) when not is_struct(grid),
    do: Map.update(grid, light, 2, &(&1 + 2))
  defp change_light_on_grid("turn on", light, grid) when not is_struct(grid),
    do: Map.update(grid, light, 1, &(&1 + 1))
  defp change_light_on_grid("turn off", light, grid) when not is_struct(grid),
    do: Map.update(grid, light, 0, &(max((&1 - 1), 0)))

  def draw_lights(input, path \\ "output/06.txt") do
    path |> Path.dirname() |> File.mkdir_p!()
    file = File.open!(path, [:write, :utf8])

    instructions = parse(input)
    grid = run_instructions_on_grid(%{}, instructions)
    {_, max_brightness} = Enum.max_by(grid, fn {_coords, brightness} -> brightness end)

    for y <- 0..999,
        x <- 0..999,
        brightness = Map.get(grid, {x, y}, 0)
    do
      light = greyscale(brightness, max_brightness)
      IO.write(file, light)
      if x == 999, do: IO.write(file, "\n")
    end

    File.close(file)
  end

  defp greyscale(brightness, max_brightness) do
    index = round((brightness / max_brightness) * (length(@greyscale) - 1))
    Enum.at(@greyscale, index)
  end
end

input = File.read!("input/06.txt")

input
|> Six.part_one()
|> IO.inspect()

input
|> Six.part_two()
|> IO.inspect()

# Six.draw_lights(input, "output/06.txt")
