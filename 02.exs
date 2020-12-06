defmodule Two do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&paper/1)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(&ribbon/1)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.split(&1, "x"))
    |> Enum.map(fn dimensions -> Enum.map(dimensions, &String.to_integer/1) end)
  end

  defp paper([x, y, z]) do
    xy = x * y
    xz = x * z
    yz = y * z
    (2 * xy) + (2 * xz) + (2 * yz) + Enum.min([xy, xz, yz])
  end

  defp ribbon([x, y, z]) do
    [a, b, _] = Enum.sort([x, y, z])
    (2 * a) + (2 * b) + (x * y * z)
  end
end

input = File.read!("input/02.txt")

input
|> Two.part_one()
|> IO.inspect()

input
|> Two.part_two()
|> IO.inspect()
