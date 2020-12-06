defmodule Five do
  def part_one(input) do
    input
    |> parse()
    |> Enum.count(&string_nice?/1)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.count(&string_extra_nice?/1)
  end

  defp parse(text) do
    text
    |> String.split("\n")
  end

  # part 1

  defp string_nice?(str), do:
    contains_at_least_three_vowels?(str)
    and contains_repeat_letter?(str)
    and not contains_blacklisted?(str)

  defp contains_at_least_three_vowels?(str), do: str =~ ~r/([aeiou].*){3,}/

  defp contains_repeat_letter?(""), do: false
  defp contains_repeat_letter?(<<a::utf8, a::utf8, _rest::binary>>), do: true
  defp contains_repeat_letter?(<<_::utf8>> <> rest), do: contains_repeat_letter?(rest)

  defp contains_blacklisted?(str), do: str =~ ~r/ab|cd|pq|xy/

  # part 2

  defp string_extra_nice?(str), do:
    contains_at_least_two_pairs?(str) and contains_gap_repeat_letter?(str)

  defp contains_at_least_two_pairs?(string, pairs \\ [])
  defp contains_at_least_two_pairs?("", _pairs), do: false
  defp contains_at_least_two_pairs?(<<_::utf8>>, _pairs), do: false
  defp contains_at_least_two_pairs?(<<a::utf8, b::utf8, rest::binary>>, pairs) do
    if <<a, b>> in pairs and <<a, b>> != List.first(pairs) do
      true
    else
      contains_at_least_two_pairs?(<<b::utf8, rest::binary>>, [<<a, b>> | pairs])
    end
  end

  defp contains_gap_repeat_letter?(""), do: false
  defp contains_gap_repeat_letter?(<<a::utf8, _::utf8, a::utf8, _rest::binary>>), do: true
  defp contains_gap_repeat_letter?(<<_::utf8>> <> rest), do: contains_gap_repeat_letter?(rest)
end

input = File.read!("input/05.txt")

input
|> Five.part_one()
|> IO.inspect()

input
|> Five.part_two()
|> IO.inspect()
