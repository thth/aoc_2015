defmodule Eleven do
  def part_one(input) do
    input
    |> parse()
    |> find_next_password()
  end

  def part_two(input) do
    input
    |> parse()
    |> find_next_password()
    |> find_next_password()
  end

  defp parse(text) do
    text
    |> String.trim()
  end

  defp find_next_password(password) do
    password
    |> increment()
    |> Stream.iterate(&increment/1)
    |> Enum.find(&valid?/1)
  end

  defp increment(to_increment, incremented \\ "")
  defp increment("", incremented), do: incremented
  defp increment(to_increment, incremented) do
    case String.split_at(to_increment, -1) do
      {head, "z"} -> increment(head, "a" <> incremented)
      {head, <<c>>} -> head <> <<c + 1>> <> incremented
    end
  end

  defp valid?(password) do
    contains_three_straight?(password)
    and no_confusing_letters?(password)
    and contains_two_pairs?(password)
  end

  defp contains_three_straight?(password) do
    password
    |> String.to_charlist()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.any?(fn [a, b, c] -> a + 1 == b and b + 1 == c end)
  end

  defp no_confusing_letters?(password), do: not String.contains?(password, ~w[i o l])

  defp contains_two_pairs?(password) when byte_size(password) <= 3, do: false
  defp contains_two_pairs?(password) do
    password
    |> String.graphemes()
    |> Enum.chunk_every(2, 1, :discard)
    |> list_contains_two_pairs?()
  end

  defp list_contains_two_pairs?(list, pairs_seen \\ [])
  defp list_contains_two_pairs?([], _), do: false
  defp list_contains_two_pairs?([[c, c] | _rest], [p]) when c != p, do: true
  defp list_contains_two_pairs?([[c, c] | rest], []), do: list_contains_two_pairs?(rest, [c])
  defp list_contains_two_pairs?([_ | rest], pairs_seen), do: list_contains_two_pairs?(rest, pairs_seen)
end

input = File.read!("input/11.txt")

input
|> Eleven.part_one()
|> IO.inspect()

input
|> Eleven.part_two()
|> IO.inspect()
