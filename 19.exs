defmodule Nineteen do
  # @start System.monotonic_time(:second)
  def part_one(input) do
    {reactions, medicine} = parse(input)

    MapSet.new([medicine])
    |> step_possibilities(reactions)
    |> MapSet.size()
  end

  def part_two(input) do
    {reactions, medicine} = parse(input)
    # done here so computed once instead of on every |> filter_possibilities
    mirrored_reactions = Enum.map(reactions, fn {inp, out} -> {inp, Enum.reverse(out)} end)

    MapSet.new([["e"]])
    |> Stream.iterate(fn molecules ->
     molecules
     |> step_possibilities(reactions)
     |> filter_possibilities(medicine, reactions, mirrored_reactions)
    end)
    |> Enum.find_index(&MapSet.member?(&1, medicine))

    # |> Stream.with_index()
    # |> Enum.find_value(fn {possibilities, i} ->
    #   IO.inspect(System.monotonic_time(:second) - @start, label: "step #{i} possibilities created at")
    #   IO.inspect(MapSet.size(possibilities), label: "size")
    #   if MapSet.member?(possibilities, medicine), do: i, else: nil
    #   # if medicine in possibilities, do: i, else: nil
    # end)
  end

  defp parse(text) do
    split_molecule_str = &String.split(&1, ~r/(?<!^)(?=[A-Z])/)
    [reactions_str, medicine_str] = String.split(text, "\n\n")
    reactions =
      ~r/(\w+) => (\w+)/
      |> Regex.scan(reactions_str, capture: :all_but_first)
      |> Enum.map(fn [inp, out] -> {inp, split_molecule_str.(out)} end)
    medicine = split_molecule_str.(medicine_str)
    {reactions, medicine}
  end

  defp step_possibilities(molecules, reactions) do
    Enum.reduce(molecules, MapSet.new(), fn molecule, acc ->
      Enum.reduce(reactions, acc, fn reaction, inner_acc ->
        MapSet.union(inner_acc, molecule_possibilities(molecule, reaction))
      end)
    end)
  end

  defp molecule_possibilities(molecule, reaction),
    do: do_molecule_possibilities([], molecule, reaction, MapSet.new())

  defp do_molecule_possibilities(_past, [], _reaction, mapset), do: mapset
  defp do_molecule_possibilities(past, [inp | rest], {inp, out}, mapset),
    do: do_molecule_possibilities(past ++ [inp], rest, {inp, out}, MapSet.put(mapset, past ++ out ++ rest))
  defp do_molecule_possibilities(past, [particle | rest], reaction, mapset),
    do: do_molecule_possibilities(past ++ [particle], rest, reaction, mapset)

  defp filter_possibilities(molecules, target, reactions, mirrored_reactions) do
    Enum.filter(molecules, fn molecule ->
      first_nonmatching_can_reach_target?(molecule, target, reactions)
      and first_nonmatching_can_reach_target?(Enum.reverse(molecule), Enum.reverse(target), mirrored_reactions)
    end)
    |> MapSet.new()
  end

  defp first_nonmatching_can_reach_target?(molecule, target, reactions, last \\ nil)
  defp first_nonmatching_can_reach_target?([], _rest_molecule, _reactions, _last), do: true
  defp first_nonmatching_can_reach_target?([atom | rest_molecule], [atom | rest_target], reactions, _last),
    do: first_nonmatching_can_reach_target?(rest_molecule, rest_target, reactions, atom)
  defp first_nonmatching_can_reach_target?([atom | _rest_mol], [target_atom | _rest_tar], reactions, last),
    do: ({last, [last, target_atom]} in reactions) or atom_can_reach_target?([atom], target_atom, reactions)

  defp atom_can_reach_target?(atoms, target_atom, reactions, checked_atoms \\ [])
  defp atom_can_reach_target?([], _, _, _), do: false
  defp atom_can_reach_target?([target_atom | _], target_atom, _, _), do: true
  defp atom_can_reach_target?([atom | rest], target_atom, reactions, checked_atoms) do
    possible_atoms =
      reactions
      |> Enum.filter(fn {inp, _out} -> inp == atom end)
      |> Enum.map(fn {_inp, out} -> hd(out) end)
      |> Enum.reject(fn out_first_atom -> out_first_atom in checked_atoms end)
    atom_can_reach_target?(possible_atoms ++ rest, target_atom, reactions, [atom | checked_atoms])
  end

end

# :observer.start()
input = File.read!("input/19.txt")
# input =
#   """
#   e => H
#   e => O
#   H => HO
#   H => OH
#   O => HH

#   HOHOHO
#   """
#   |> String.trim()

input
|> Nineteen.part_one()
|> IO.inspect()

input
|> Nineteen.part_two()
|> IO.inspect()
