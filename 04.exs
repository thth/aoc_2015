defmodule Four do
  def part_one(input), do: find_hash(input, "00000")
  def part_two(input), do: find_hash(input, "000000")

  defp find_hash(input, start, n \\ 1) do
    case md5("#{input}#{n}") |> String.starts_with?(start) do
      true  -> n
      false -> find_hash(input, start, n + 1)
    end
  end

  defp md5(input), do: :crypto.hash(:md5, input) |> Base.encode16()
end

input = File.read!("input/04.txt")

input
|> Four.part_one()
|> IO.inspect()

input
|> Four.part_two()
|> IO.inspect()
