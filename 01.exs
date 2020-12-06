defmodule One do
  def part_one(input) do
    input
    |> parse()
    |> Enum.reduce(0, fn
      "(", floor -> floor + 1
      ")", floor -> floor - 1
    end)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.with_index(1)
    |> Enum.reduce_while(0, fn
      {")", i}, 0     -> {:halt, i}
      {"(", _}, floor -> {:cont, floor + 1}
      {")", _}, floor -> {:cont, floor - 1} 
    end)
  end

  defp parse(text) do
    text
    |> String.graphemes()
  end
end

input = File.read!("input/01.txt")

input
|> One.part_one()
|> IO.inspect()

input
|> One.part_two()
|> IO.inspect()
