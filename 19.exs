defmodule Nineteen do
  # @start System.monotonic_time(:second)
  def part_one(input) do
    {reactions, medicine} = parse(input)

    MapSet.new([medicine])
    |> step_possibilities(reactions)
    |> MapSet.size()
  end

  @doc """
  assumptions:
    - outputs are unique
    - outputs longer than inputs
    - no outputs are a fully contained by another output
  """
  def part_two(input) do
    {reactions, medicine} = parse(input)
    backwards_find(medicine, reactions)
  end

  # def part_two(input) do
  #   {reactions, medicine} = parse(input)
  #   reactions_map =
  #     Enum.reduce(reactions, %{}, fn {inp, out}, acc ->
  #       Map.update(acc, inp, [out], fn v -> [out | v] end)
  #     end)

  #   find_shortest(["e"], medicine, reactions_map)
  # end

  # def part_two(input) do
  #   {reactions, medicine} = parse(input)
  #   # done here so computed once instead of on every |> filter_possibilities
  #   mirrored_reactions = Enum.map(reactions, fn {inp, out} -> {inp, Enum.reverse(out)} end)

  #   MapSet.new([["e"]])
  #   |> Stream.iterate(fn molecules ->
  #    molecules
  #    |> step_possibilities(reactions)
  #    |> filter_possibilities(medicine, reactions, mirrored_reactions)
  #   end)
  #   |> Enum.find_index(&MapSet.member?(&1, medicine))

  #   # |> Stream.with_index()
  #   # |> Enum.find_value(fn {possibilities, i} ->
  #   #   IO.inspect(System.monotonic_time(:second) - @start, label: "step #{i} possibilities created at")
  #   #   IO.inspect(MapSet.size(possibilities), label: "size")
  #   #   if MapSet.member?(possibilities, medicine), do: i, else: nil
  #   #   # if medicine in possibilities, do: i, else: nil
  #   # end)
  # end

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

  # defp filter_possibilities(molecules, target, reactions, mirrored_reactions) do
  #   Enum.filter(molecules, fn molecule ->
  #     first_nonmatching_can_reach_target?(molecule, target, reactions)
  #     and first_nonmatching_can_reach_target?(Enum.reverse(molecule), Enum.reverse(target), mirrored_reactions)
  #   end)
  #   |> MapSet.new()
  # end

  # defp first_nonmatching_can_reach_target?(molecule, target, reactions, last \\ nil)
  # defp first_nonmatching_can_reach_target?([], _rest_molecule, _reactions, _last), do: true
  # defp first_nonmatching_can_reach_target?([atom | rest_molecule], [atom | rest_target], reactions, _last),
  #   do: first_nonmatching_can_reach_target?(rest_molecule, rest_target, reactions, atom)
  # defp first_nonmatching_can_reach_target?([atom | _rest_mol], [target_atom | _rest_tar], reactions, last),
  #   do: ({last, [last, target_atom]} in reactions) or atom_can_reach_target?([atom], target_atom, reactions)

  # defp atom_can_reach_target?(atoms, target_atom, reactions, checked_atoms \\ [])
  # defp atom_can_reach_target?([], _, _, _), do: false
  # defp atom_can_reach_target?([target_atom | _], target_atom, _, _), do: true
  # defp atom_can_reach_target?([atom | rest], target_atom, reactions, checked_atoms) do
  #   possible_atoms =
  #     reactions
  #     |> Enum.filter(fn {inp, _out} -> inp == atom end)
  #     |> Enum.map(fn {_inp, out} -> hd(out) end)
  #     |> Enum.reject(fn out_first_atom -> out_first_atom in checked_atoms end)
  #   atom_can_reach_target?(possible_atoms ++ rest, target_atom, reactions, [atom | checked_atoms])
  # end

  # defp find_shortest(molecule, medicine, reactions_map),
  #   do: do_shortest([{molecule, medicine, nil, 0}], reactions_map, nil)

  # defp do_shortest([], _, shortest), do: shortest
  # # can be optimized by comparing w/ max size increase per step
  # defp do_shortest([{_molecule, _target, _last, steps} | rest] = list, map, shortest) when steps >= shortest do
  #   # IO.inspect(list, label: 0)
  #   do_shortest(rest, map, shortest)
  # end
  # defp do_shortest([{[], [], _last, steps} | rest] = list, map, _not_shorter) do
  #   # IO.inspect(list, label: 1)
  #   IO.inspect(steps, label: "molecule found")
  #   do_shortest(rest, map, steps)
  # end

  # defp do_shortest([{[], _, _last, _steps} | rest] = list, map, shortest) do
  #   # IO.inspect(list, label: 2)
  #   do_shortest(rest, map, shortest)
  # end

  # # defp do_shortest([{[atom | rest_molecule], [atom | rest_target], _last, steps} | rest], map, shortest),
  #   # do: do_shortest([{rest_molecule, rest_target, atom, steps} | rest], map, shortest)

  # defp do_shortest([{molecule, target, _, _} | rest] = list, map, shortest) when length(molecule) > length(target) do
  #   # IO.inspect(list, label: 3)
  #   do_shortest(rest, map, shortest)
  # end

  # defp do_shortest([{[atom | rest_molecule], [atom | rest_target], last, steps} | rest] = list, map, shortest) do
  #   # IO.inspect(list, label: 4)
  #   to_check =
  #     Map.get(map, atom, [])
  #     |> Enum.filter(fn [first_atom | _] -> atom_can_match?(first_atom, atom, map) end)
  #     # last here can be nil I think
  #     |> Enum.map(fn out -> {out ++ rest_molecule, [atom | rest_target], last, steps + 1} end)
  #     |> Kernel.++([{rest_molecule, rest_target, atom, steps}])
  #   do_shortest(to_check ++ rest, map, shortest)
  # end

  # defp do_shortest([{[atom | rest_molecule], [target_atom | rest_target], last, steps} | rest] = list, map, shortest) do
  #    # IO.inspect(list, label: 5)
  #   # if [last, target_atom] in Map.get(map, last, []) do
  #   #   do_shortest([{[atom | rest_molecule], rest_target, target_atom, steps + 1} | rest], map, shortest)
  #   # else
  #     to_check =
  #       Map.get(map, atom, [])
  #       |> Enum.filter(fn [first_atom | _] -> atom_can_match?(first_atom, target_atom, map) end)
  #       # last here can be nil I think
  #       |> Enum.map(fn out -> {out ++ rest_molecule, [target_atom | rest_target], last, steps + 1} end)
  #     do_shortest(to_check ++ rest, map, shortest)
  #   # end
  # end

  # defp atom_can_match?(atom, target_atom, map) when is_binary(atom),
  #   do: atom_can_match?([atom], target_atom, map, [])
  # defp atom_can_match?([], _, _, _), do: false
  # defp atom_can_match?([target_atom | _], target_atom, _, _), do: true
  # defp atom_can_match?([atom | rest], target_atom, map, checked_atoms) do
  #   possible_intermediaries =
  #     map
  #     |> Map.get(atom, [])
  #     |> Enum.map(fn molecule -> List.first(molecule) end)
  #     |> Kernel.--(checked_atoms)
  #   atom_can_match?(possible_intermediaries ++ rest, target_atom, map, [atom | checked_atoms])
  # end

  defp backwards_find(molecule, reactions), do: do_backwards([molecule], reactions)

  defp do_backwards(to_revert, reverted \\ MapSet.new(), seen \\ MapSet.new(), reactions, steps \\ 0)
  defp do_backwards([], reverted, seen, reactions, steps) do
    if MapSet.member?(reverted, ["e"]) do
      steps + 1
    else
      case MapSet.size(reverted) do
        0 -> {:error, {"e not found", seen, steps}}
        n ->
          longest_reverted = reverted |> Enum.max_by(&length/1) |> length()
          cleaned_seen =
            seen
            |> Enum.filter(fn molecule -> length(molecule) <= longest_reverted end)
            |> MapSet.new()
          IO.puts("running step #{steps + 1} on #{n} molecules w/"
            <> " longest_reverted: #{longest_reverted}, seen: #{MapSet.size(cleaned_seen)}")
          do_backwards(MapSet.to_list(reverted), MapSet.new(), cleaned_seen, reactions, steps + 1)
      end
    end
  end
  defp do_backwards([molecule | rest], reverted, seen, reactions, steps) do
    possible_reverts = get_reverts(molecule, reactions)
    unseen_reverts = MapSet.difference(possible_reverts, seen)
    do_backwards(rest, MapSet.union(reverted, unseen_reverts), MapSet.union(seen, unseen_reverts), reactions, steps)
  end

  defp get_reverts(molecule, reactions) do
    if length(molecule) > 2 do
      do_reverts(molecule, Enum.filter(reactions, fn {inp, out} -> inp != "e" end))
    else
      do_reverts(molecule, reactions)
    end
  end

  defp do_reverts(past \\ [], to_check, reactions, reverts \\ MapSet.new())
  defp do_reverts(_past, [], _reactions, reverts), do: reverts
  defp do_reverts(past, [first | rest_to_check] = to_check, reactions, reverts) do
    new_reverts =
      Enum.reduce(reactions, reverts, fn {inp, out}, acc ->
        case Enum.split(to_check, length(out)) do
          {^out, rest} -> MapSet.put(acc, past ++ [inp] ++ rest)
          _ -> acc
        end
      end)
    do_reverts(past ++ [first], rest_to_check, reactions, new_reverts)
  end
end

# :observer.start
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
