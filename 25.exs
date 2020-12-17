defmodule TwentyFive do
  def part_one(input) do
    {row, col} = parse(input)
    nth = find_nth(row, col)
    Stream.iterate(20151125, &step/1)
    |> Enum.at(nth - 1)
  end

  defp parse(text) do
    [[row], [col]] = Regex.scan(~r/\d+/, text)
    {String.to_integer(row), String.to_integer(col)}
  end

  defp find_nth(row, col) do
    # n_iteration of triangle number of current triangle
    t = row + col - 1
    triangle_number = div(t * (t + 1), 2)
    # subtracted by progress in latest line of triangle
    triangle_number - (t - col)
  end

  defp step(n) do
    rem(n * 252533, 33554393)
  end
end

input = File.read!("input/25.txt")

input
|> TwentyFive.part_one()
|> IO.inspect()
