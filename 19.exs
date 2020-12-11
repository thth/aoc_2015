defmodule Nineteen do
  def part_one(input) do
    {reactions, medicine} = parse(input)

    MapSet.new([medicine])
    |> step_possibilities(reactions)
    |> MapSet.size()

    # Enum.reduce(reactions, MapSet.new(), fn reaction, acc ->
    #   MapSet.union(acc, possibilities(medicine, reaction))
    # end)

    # reactions
    # |> Enum.reduce(MapSet.new(), fn reaction, acc ->
    #   MapSet.union(acc, possibilities(medicine, reaction))
    # end)
    # |> MapSet.size()
  end

  def part_two(input) do
    input
    |> parse()
  end

  defp parse(text) do
    split_molecule_str = &String.split(&1, ~r/(?<!^)(?=[A-Z])/)
    [reactions_str, medicine_str] = String.split(text, "\n\n")
    reactions =
      ~r/(\w+) => (\w+)/
      |> Regex.scan(reactions_str, capture: :all_but_first)
      |> Enum.map(fn [inp, out] -> {inp, split_molecule_str.(out)} end)
      # |> Enum.reduce(%{}, fn [inp, out], acc ->
      #   Map.update(acc, inp, [out], fn list -> [out | list] end)
      # end)
    medicine = split_molecule_str.(medicine_str)
    {reactions, medicine}
  end

  # defp possibilities(med, reaction), do: possibilities("", med, reaction, MapSet.new())

  # defp possibilities(_past, med, {inp, _out}, mapset) when byte_size(inp) > byte_size(med), do: mapset
  # defp possibilities(past, med, {inp, out}, mapset) do
  #   case String.split_at(med, byte_size(inp)) do
  #     {^inp, rest} ->
  #       new = past <> out <> rest
  #       possibilities(past <> inp, rest, {inp, out}, MapSet.put(mapset, new))
  #     _ ->
  #       {h, t} = String.split_at(med, 1)
  #       possibilities(past <> h, t, {inp, out}, mapset)
  #   end
  # end

  defp step_possibilities(molecules, reactions) do
    Enum.reduce(molecules, MapSet.new(), fn molecule, acc ->
      Enum.reduce(reactions, acc, fn reaction, inner_acc ->
        MapSet.union(inner_acc, possibilities(molecule, reaction))
      end)
    end)
  end

  defp possibilities(molecule, reaction), do: do_possibilities([], molecule, reaction, MapSet.new())

  defp do_possibilities(_past, [], _reaction, mapset), do: mapset
  defp do_possibilities(past, [inp | rest], {inp, out}, mapset),
    do: do_possibilities(past ++ [inp], rest, {inp, out}, MapSet.put(mapset, past ++ out ++ rest))
  defp do_possibilities(past, [particle | rest], reaction, mapset),
    do: do_possibilities(past ++ [particle], rest, reaction, mapset)
end

input = File.read!("input/19.txt")
# input =
#   """
#   H => HO
#   H => OH
#   O => HH

#   HOH
#   """
#   |> String.trim()

input
|> Nineteen.part_one()
|> IO.inspect()

# input
# |> Nineteen.part_two()
# |> IO.inspect()
