defmodule Ten do
  def part_one(input) do
    input
    |> parse()
    |> Stream.iterate(&look_and_say/1)
    |> Enum.at(40)
    |> length()
  end

  def part_two(input) do
    input
    |> parse()
    |> Stream.iterate(&look_and_say/1)
    |> Enum.at(50)
    |> length()
  end

  defp parse(text) do
    text
    |> String.to_integer()
    |> Integer.digits()
  end

  # part 2: 500ms
  defp look_and_say(digits) do
    [n | rest] = Enum.reverse(digits)
    look_and_say(rest, [], n, 1)
  end
  defp look_and_say([], acc, last_digit, count), do: [count, last_digit | acc]
  defp look_and_say([digit | rest], acc, digit, count),
    do: look_and_say(rest, acc, digit, count + 1)
  defp look_and_say([digit | rest], acc, last_digit, count),
    do: look_and_say(rest, [count, last_digit | acc], digit, 1)

  # part 2: 3937ms
  # defp look_and_say(digits) do
  #   digits
  #   |> Enum.chunk_by(&(&1))
  #   |> Enum.reverse()
  #   |> Enum.reduce([], fn [n | _] = chunk, acc -> [length(chunk), n | acc] end)
  # end

  # part 2: 4718ms
  # defp look_and_say(digits) do
  #   digits
  #   |> Enum.chunk_by(&(&1))
  #   |> Enum.map(fn [n | _] = list -> [length(list), n] end)
  #   |> List.flatten()
  # end
end

input = File.read!("input/10.txt")

input
|> Ten.part_one()
|> IO.inspect()

# start_time = System.monotonic_time(:millisecond)

input
|> Ten.part_two()
|> IO.inspect()

# end_time = System.monotonic_time(:millisecond)
# IO.inspect(end_time - start_time, label: "part 2 execution in ms")
