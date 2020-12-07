defmodule Eight do
  def part_one(input) do
    strings = parse(input)
    code_chars_total = Enum.reduce(strings,  0, &(&2 + String.length(&1)))
    memory_chars_total =
      strings
      |> Enum.map(&unencode_string(&1))
      |> Enum.reduce(0, &(&2 + String.length(&1)))

    code_chars_total - memory_chars_total
  end

  def part_two(input) do
    strings = parse(input)
    code_chars_total = Enum.reduce(strings,  0, &(&2 + String.length(&1)))
    encoded_chars_total =
      strings
      |> Enum.map(&encode_string(&1))
      |> IO.inspect()
      |> Enum.reduce(0, &(&2 + String.length(&1)))

    encoded_chars_total - code_chars_total
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split("\n")
  end

  defp unencode_string(string) do
    string
    |> String.slice(1..-2)
    |> String.replace("\\\\", "\\")
    |> String.replace("\\\"", "\"")
    |> String.replace(~r/\\x[0-9a-f]{2}/, fn "\\x" <> hex ->
      [String.to_integer(hex, 16)] |> List.to_string()
    end)
  end

  defp encode_string(string) do
    inner = String.replace(string, ["\\", "\""], fn
      "\\" -> "\\\\"
      "\"" -> "\\\""
    end)
    "\"#{inner}\""
  end
end

input = File.read!("input/08.txt")

input
|> Eight.part_one()
|> IO.inspect()

input
|> Eight.part_two()
|> IO.inspect()
