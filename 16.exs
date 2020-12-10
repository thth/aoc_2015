defmodule Sixteen do
  @real_sue %{
    "children" => 3,
    "cats" => 7,
    "samoyeds" => 2,
    "pomeranians" => 3,
    "akitas" => 0,
    "vizslas" => 0,
    "goldfish" => 5,
    "trees" => 3,
    "cars" => 2,
    "perfumes" => 1
  }

  def part_one(input) do
    input
    |> parse()
    |> Enum.find(fn {_n, properties} ->
      Enum.all?(properties, fn {k, v} -> @real_sue[k] == v end)
    end)
    |> elem(0)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.find(fn {_n, properties} ->
      Enum.all?(properties, &sue?/1)
    end)
    |> elem(0)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.into(%{}, fn line ->
      [left, right] = String.split(line, ":", parts: 2)
      n =
        Regex.run(~r/(\d+)/, left, capture: :all_but_first)
        |> hd()
        |> String.to_integer()
      properties =
        Regex.scan(~r/(\w+): (\d+)\b/, right, capture: :all_but_first)
        |> Enum.into(%{}, fn [k, v] -> {k, String.to_integer(v)} end)

      {n, properties}
    end)
  end

  defp sue?({prop, x}) when prop in ~w[cats trees], do: @real_sue[prop] < x
  defp sue?({prop, x}) when prop in ~w[pomeranians goldfish], do: @real_sue[prop] > x
  defp sue?({prop, x}), do: @real_sue[prop] == x
end

input = File.read!("input/16.txt")

input
|> Sixteen.part_one()
|> IO.inspect()

input
|> Sixteen.part_two()
|> IO.inspect()
