defmodule Nineteen do
  # @start System.monotonic_time(:second)
  def part_one(input) do
    {reactions, medicine} = parse(input)

    MapSet.new([medicine])
    |> step_possibilities(reactions)
    |> MapSet.size()
  end

  def part_two(input, steps \\ 0) do
    {reactions_list, medicine} = parse(input)

    {molecule, steps} = step_revert(medicine, reactions_list, steps)
    molecule_str = molecule |> Enum.map(fn atom -> atom.name end) |> Enum.join()
    {molecule, steps, molecule_str}
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

# part 1 stuff
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

# unsuccessful part 2 attempts
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

  # def part_two(input) do
  #   {reactions, medicine} = parse(input)
  #   reactions_map =
  #     Enum.reduce(reactions, %{}, fn {inp, out}, acc ->
  #       Map.update(acc, inp, [out], fn v -> [out | v] end)
  #     end)

  #   find_shortest(["e"], medicine, reactions_map)
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

  # @doc """
  # assumptions:
  #   - outputs are unique
  #   - outputs longer than inputs
  #   - no outputs are a fully contained by another output
  # """
  # def part_two(input) do
  #   {reactions, medicine} = parse(input)
  #   backwards_find(medicine, reactions)
  # end

  # defp backwards_find(molecule, reactions), do: do_backwards([molecule], reactions)

  # defp do_backwards(to_revert, reverted \\ MapSet.new(), seen \\ MapSet.new(), reactions, steps \\ 0)
  # defp do_backwards([], reverted, seen, reactions, steps) do
  #   if MapSet.member?(reverted, ["e"]) do
  #     steps + 1
  #   else
  #     case MapSet.size(reverted) do
  #       0 -> {:error, {"e not found", seen, steps}}
  #       n ->
  #         longest_reverted = reverted |> Enum.max_by(&length/1) |> length()
  #         cleaned_seen =
  #           seen
  #           |> Enum.filter(fn molecule -> length(molecule) <= longest_reverted end)
  #           |> MapSet.new()
  #         IO.puts("running step #{steps + 1} on #{n} molecules w/"
  #           <> " longest_reverted: #{longest_reverted}, seen: #{MapSet.size(cleaned_seen)}")
  #         do_backwards(MapSet.to_list(reverted), MapSet.new(), cleaned_seen, reactions, steps + 1)
  #     end
  #   end
  # end
  # defp do_backwards([molecule | rest], reverted, seen, reactions, steps) do
  #   possible_reverts = get_reverts(molecule, reactions)
  #   unseen_reverts = MapSet.difference(possible_reverts, seen)
  #   do_backwards(rest, MapSet.union(reverted, unseen_reverts), MapSet.union(seen, unseen_reverts), reactions, steps)
  # end

  # defp get_reverts(molecule, reactions) do
  #   if length(molecule) > 2 do
  #     do_reverts(molecule, Enum.filter(reactions, fn {inp, out} -> inp != "e" end))
  #   else
  #     do_reverts(molecule, reactions)
  #   end
  # end

  # defp do_reverts(past \\ [], to_check, reactions, reverts \\ MapSet.new())
  # defp do_reverts(_past, [], _reactions, reverts), do: reverts
  # defp do_reverts(past, [first | rest_to_check] = to_check, reactions, reverts) do
  #   new_reverts =
  #     Enum.reduce(reactions, reverts, fn {inp, out}, acc ->
  #       case Enum.split(to_check, length(out)) do
  #         {^out, rest} -> MapSet.put(acc, past ++ [inp] ++ rest)
  #         _ -> acc
  #       end
  #     end)
  #   do_reverts(past ++ [first], rest_to_check, reactions, new_reverts)
  # end
###

  defmodule Atom do
    defstruct [:name, :reactions]

    def new(name, reactions) do
      %__MODULE__{name: name, reactions: reactions.backwards[name]}
    end
  end

  defp step_revert(molecule, reactions_list, steps) do
    reactions =
      %{list: reactions_list}
      |> parse_backwards()
      |> parse_parens()

    atomed_molecule =
      Enum.map(molecule, fn atom_name ->
        Atom.new(atom_name, reactions)
      end)

    do_step_revert(atomed_molecule, reactions, steps)
  end

  defp parse_backwards(%{list: list} = reactions) do
    backwards =
      # atoms
      Enum.reduce(list, MapSet.new(), fn {_inp, out}, acc ->
        out
        |> MapSet.new()
        |> MapSet.union(acc)
      end)
      # key: atom, value: any reaction tuple w/ atom
      |> Enum.map(fn atom ->
        backwards_list = Enum.filter(list, fn {_inp, out} -> Enum.member?(out, atom) end)
        {atom, backwards_list}
      end)
      |> Enum.into(%{})
    Map.put(reactions, :backwards, backwards)
  end

  defp parse_parens(%{list: list} = reactions) do
    atoms_in_inp = Enum.reduce(list, MapSet.new(), fn {inp, _out}, acc ->
      MapSet.put(acc, inp)
    end)

    atoms_in_out = Enum.reduce(list, MapSet.new(), fn {_inp, out}, acc ->
      out
      |> MapSet.new()
      |> MapSet.union(acc)
    end)

    non_inps = MapSet.difference(atoms_in_out, atoms_in_inp) |> Enum.to_list()
    parens_candidates =
      for a <- non_inps,
          b <- non_inps -- [a] do
        {a, b}
      end
    parens =
      parens_candidates
      |> Enum.filter(fn {a, b} ->
        outs_with_pair =
          list
          |> Enum.map(fn {_inp, out} -> out end)
          |> Enum.filter(fn out ->
            MapSet.subset?(MapSet.new([a, b]), MapSet.new(out))
          end)
        Enum.any?(outs_with_pair, fn out ->
          right_most_a_index = (length(out) - 1) - (out |> Enum.reverse() |> Enum.find_index(&(&1 == a)))
          left_most_b_index = Enum.find_index(out, &(&1 == b))
          cond do
            right_most_a_index + 1 == left_most_b_index -> false
            Enum.any?(non_inps, &(&1 in Enum.slice(out, (right_most_a_index + 1)..(left_most_b_index - 1)))) -> false
            true -> right_most_a_index < left_most_b_index
          end
        end)
      end)
      |> Enum.reduce(%{}, fn {a, b}, acc ->
        Map.update(acc, a, {[b], []}, fn {paren_ends, []} -> {[b | paren_ends], []}end)
      end)
      |> Enum.map(fn {paren_start, {paren_ends, []}} ->
        not_paren_ends = non_inps -- paren_ends
        {paren_start, {paren_ends, not_paren_ends}}
      end)
      |> Enum.into(%{})

    Map.put(reactions, :parens, parens)
  end

  # - for every atom.reactions, filter out:
  #   - every reaction where first atom left of current atom in output cannot be derived from current left atom
  #   - every reaction where first atom right of current atom in output cannot be derived from current right atom
  # - from list of atoms left of current mapped from reactions:
  #   - if _empty_ in list, do nothing
  #   - if no empty, filter out reactions of atom left of current in molecule with:
  #     - left atom being left of current atom in output (anywhere or only rightmost case?)
  #     - reaction paths w/ atom on right end of output that can reach desired left atom (keep a set of seen)
  # - repeat above step mirrored to the right
  # defp do_step_revert(molecule, reactions, steps \\ 0)
  defp do_step_revert(["e"], _, steps), do: steps
  defp do_step_revert(molecule, reactions, steps) do
    with :nop <- filter_molecule_reactions_by_atom_neighbors(molecule, reactions),
         :nop <- filter_molecule_reactions_by_atom_neighbors_reactions(molecule, reactions),
         :nop <- revert_simple_addition(molecule, reactions),
         :nop <- revert_matching_unique_reaction(molecule, reactions),
         :nop <- revert_sole_unique_reaction(molecule, reactions)
         # :nop <- filter_parens_reactions(molecule, reactions)
    do
      {molecule, steps}
    else
      {:progress, progressed, stepped} ->
        do_step_revert(progressed, reactions, steps + stepped)
    end
  end

  ## filter_molecule_reactions_by_atom_neighbors
  # this only filters out by atom immediately left/right;
  # possible to filter by all atoms on every side recursively
  defp filter_molecule_reactions_by_atom_neighbors(molecule, reactions) do
    filtered_molecule =
      molecule
      |> Enum.with_index()
      |> Enum.map(fn {atom, i} ->
        left = if i == 0, do: nil, else: molecule |> Enum.at(i - 1) |> Map.get(:name)
        right = if i + 1 == length(molecule), do: nil, else: molecule |> Enum.at(i + 1) |> Map.get(:name)
        filtered_reactions = filter_atom_reactions(atom, left, right, reactions)
        %Atom{atom | reactions: filtered_reactions}
      end)

    if molecule == filtered_molecule do
      :nop
    else
      {:progress, filtered_molecule, 0}
    end
  end

  defp filter_atom_reactions(atom, left, right, reactions) do
    atom.reactions
    |> Enum.filter(fn {_inp, out} -> left_can_reach_target?(out, atom.name, left, reactions) end)
    |> Enum.filter(fn {_inp, out} -> right_can_reach_target?(out, atom.name, right, reactions) end)
  end

  defp left_can_reach_target?([atom_name | _rest], atom_name, nil, _), do: true
  defp left_can_reach_target?(_out, _atom_name, nil, _), do: false
  defp left_can_reach_target?(out, atom_name, left, reactions) do
    out
    |> Enum.with_index()
    |> Enum.any?(fn
      {^atom_name, 0} -> true
      {^atom_name, i} ->
        target = Enum.at(out, i - 1)
        left_to_target?(left, target, reactions)
      _ -> false
    end)
  end

  # defp left_to_target?(target, target, reactions), do: true
  defp left_to_target?(atom, target, reactions), do: left_to_target?([atom], target, reactions, [])
  defp left_to_target?([], _, _, _), do: false
  defp left_to_target?([target | _], target, _, _), do: true
  defp left_to_target?([atom | rest], target, reactions, checked) do
    possible_intermediaries =
      reactions.list
      |> Enum.filter(fn {_inp, out} -> List.last(out) == atom end)
      |> Enum.map(fn {inp, _out} -> inp end)
      |> Kernel.--(checked)
    left_to_target?(possible_intermediaries ++ rest, target, reactions, [atom | checked])
  end

  defp right_can_reach_target?(out, atom_name, nil, _), do: List.last(out) == atom_name
  defp right_can_reach_target?(out, atom_name, right, reactions) do
    out
    |> Enum.with_index()
    |> Enum.any?(fn
      {^atom_name, i} ->
        case Enum.at(out, i + 1) do
          # atom in out is rightmost
          nil -> true
          target ->
            right_to_target?(right, target, reactions)
        end
      _ -> false
    end)
  end

  defp right_to_target?(atom, target, reactions), do: right_to_target?([atom], target, reactions, [])
  defp right_to_target?([], _, _, _), do: false
  defp right_to_target?([target | _], target, _, _), do: true
  defp right_to_target?([atom | rest], target, reactions, checked) do
    possible_intermediaries =
      reactions.list
      |> Enum.filter(fn {_inp, out} -> List.first(out) == atom end)
      |> Enum.map(fn {inp, _out} -> inp end)
      |> Kernel.--(checked)
    right_to_target?(possible_intermediaries ++ rest, target, reactions, [atom | checked])
  end

  ## filter_molecule_reactions_by_atom_neighbors_reactions
  def filter_molecule_reactions_by_atom_neighbors_reactions(molecule, reactions) do
    filtered_molecule =
      molecule
      |> filter_molecule_left_neighbors_by_reactions(reactions)
      |> filter_molecule_right_neighbors_by_reactions(reactions)

    if molecule == filtered_molecule do
      :nop
    else
      {:progress, filtered_molecule, 0}
    end
  end

  defp filter_molecule_left_neighbors_by_reactions(molecule, reactions) do
    1..(length(molecule) - 1)
    |> Enum.reduce(molecule, fn
      i, acc ->
        atom = Enum.at(acc, i)
        case possible_left_targets(atom) do
          :all -> acc
          targets ->
            List.update_at(acc, i - 1, fn left ->
              filter_reactions_as_left_neighbor_to(left, atom.name, targets, reactions)
            end)
        end
    end)
  end

  defp possible_left_targets(%Atom{name: name} = atom) do
    targets_set =
      Enum.reduce(atom.reactions, MapSet.new(), fn {_inp, out}, acc ->
        out
        |> Enum.with_index()
        |> Enum.reduce(acc, fn
          {^name, 0}, inner_acc -> MapSet.put(inner_acc, nil)
          {^name, i}, inner_acc -> MapSet.put(inner_acc, Enum.at(out, i - 1))
          _, inner_acc -> inner_acc
        end)
      end)
    if MapSet.member?(targets_set, nil), do: :all, else: targets_set
  end

  defp filter_reactions_as_left_neighbor_to(atom, right_neighbor_name, targets, reactions) do
    filtered_reactions =
      atom.reactions
      |> Enum.filter(fn {inp, out} ->
        sublist?(out, [atom.name, right_neighbor_name])
        or (List.last(out) == atom.name and inp_can_reach_targets?(inp, targets, reactions))
      end)
    %Atom{atom | reactions: filtered_reactions}
  end

  defp filter_molecule_right_neighbors_by_reactions(molecule, reactions) do
    0..(length(molecule) - 2)
    |> Enum.reduce(molecule, fn
      i, acc ->
        atom = Enum.at(acc, i)
        case possible_right_targets(atom) do
          :all -> acc
          targets ->
            List.update_at(acc, i + 1, fn right ->
              filter_reactions_as_right_neighbor_to(right, atom.name, targets, reactions)
            end)
        end
    end)
  end

  defp possible_right_targets(%Atom{name: name} = atom) do
    targets_set =
      Enum.reduce(atom.reactions, MapSet.new(), fn {_inp, out}, acc ->
        max_i = length(out) - 1
        out
        |> Enum.with_index()
        |> Enum.reduce(acc, fn
          {^name, ^max_i}, inner_acc -> MapSet.put(inner_acc, nil)
          {^name, i}, inner_acc -> MapSet.put(inner_acc, Enum.at(out, i + 1))
          _, inner_acc -> inner_acc
        end)
      end)
    if MapSet.member?(targets_set, nil), do: :all, else: targets_set
  end

  defp filter_reactions_as_right_neighbor_to(atom, left_neighbor_name, targets, reactions) do
    filtered_reactions =
      atom.reactions
      |> Enum.filter(fn {inp, out} ->
        sublist?(out, [left_neighbor_name, atom.name])
        or (List.first(out) == atom.name and inp_can_reach_targets?(inp, targets, reactions))
      end)
    %Atom{atom | reactions: filtered_reactions}
  end

  defp inp_can_reach_targets?(inp, targets, reactions), do: inp_can_reach_targets?([inp], targets, reactions, [])
  defp inp_can_reach_targets?([], _, _, _), do: false
  defp inp_can_reach_targets?([head | rest], targets, reactions, checked) do
    cond do
      head in targets -> true
      head in checked ->
        inp_can_reach_targets?(rest, targets, reactions, checked)
      true ->
        possible_intermediaries =
          reactions.backwards
          |> Map.get(head, [])
          |> Enum.map(fn {inp, _out} -> inp end)
          |> Enum.dedup()
        inp_can_reach_targets?(possible_intermediaries ++ rest, targets, reactions, [head | checked])
    end
  end

  defp sublist?([], _), do: false
  defp sublist?(parent, check), do: List.starts_with?(parent, check) or sublist?(tl(parent), check)

  defp revert_simple_addition(molecule, reactions) do
    to_revert =
      molecule
      |> Enum.with_index()
      |> Enum.find_value(fn {%Atom{name: atom_name} = atom, i} ->
        Enum.all?(atom.reactions, &is_simple_addition?/1)
        and Enum.find_value(atom.reactions, fn
            {l, [l, ^atom_name]} ->
              if l == (molecule |> Enum.at(i - 1) |> Map.get(:name)), do: {i - 1, l}, else: nil
            {r, [^atom_name, r]} ->
              if r == (molecule |> Enum.at(i + 1) |> Map.get(:name)), do: {i, r}, else: nil
          end)
      end)
    case to_revert do
      nil -> :nop
      {i, replacement_name} ->
        prev = Enum.slice(molecule, 0, i)
        post = Enum.slice(molecule, (i + 2)..-1)
        new_atom = Atom.new(replacement_name, reactions)
        new_molecule = prev ++ [new_atom] ++ post
        {:progress, new_molecule, 1}
    end
  end

  defp is_simple_addition?({inp, [inp, _]}), do: true
  defp is_simple_addition?({inp, [_, inp]}), do: true
  defp is_simple_addition?(_), do: false

  defp revert_matching_unique_reaction(molecule, reactions) do
    to_revert =
      molecule
      |> Enum.with_index()
      |> Enum.find_value(fn
        {%Atom{name: first, reactions: [{_, [first | rest]} = reaction]}, i} ->
          revert? =
            rest
            |> Enum.with_index(i + 1)
            |> Enum.all?(fn {other_name, j} ->
              case Enum.at(molecule, j) do
                %Atom{reactions: [^reaction], name: ^other_name} -> true
                _ -> false
              end
            end)
          if revert?, do: {i, reaction}, else: nil
        {_, _} -> nil
      end)
    case to_revert do
      nil -> :nop
      {i, {inp, out}} ->
        prev = Enum.slice(molecule, 0, i)
        post = Enum.slice(molecule, (i + length(out))..-1)
        new_atom = Atom.new(inp, reactions)
        new_molecule = prev ++ [new_atom] ++ post
        {:progress, new_molecule, 1}
    end
  end

  defp revert_sole_unique_reaction(molecule, reactions) do
    to_revert =
      molecule
      |> Enum.with_index()
      |> Enum.find_value(fn
        # matching on only 1 possible reaction
        {%Atom{name: atom_name, reactions: [{inp, out}]}, i} ->
          # matching only outs with 1 of atom_name, hopefully won't matter? (but might)
          if Enum.count(out, &(&1 == atom_name)) == 1 do
            atom_offset = Enum.find_index(out, &(&1 == atom_name))

            all_match? =
              out
              |> Enum.with_index(i - atom_offset)
              |> Enum.all?(fn {other_atom, j} ->
                atom_at_j = Enum.at(molecule, j)
                (other_atom == atom_at_j.name)
                and atom_cant_reach_itself?(atom_at_j, reactions)
              end)

            if all_match?, do: {(i - atom_offset), {inp, out}}, else: nil
          else
            nil
          end
        {_, _} -> nil
      end)
    case to_revert do
      nil -> :nop
      {i, {inp, out}} ->
        prev = Enum.slice(molecule, 0, i)
        post = Enum.slice(molecule, (i + length(out))..-1)
        new_atom = Atom.new(inp, reactions)
        new_molecule = prev ++ [new_atom] ++ post
        {:progress, new_molecule, 1}
    end
  end

  defp atom_cant_reach_itself?(%Atom{name: name, reactions: reaction_list}, reactions) do
    inps = Enum.map(reaction_list, fn {inp, _out} -> inp end)
    Enum.all?(inps, fn inp -> not inp_can_reach_targets?(inp, [name], reactions) end)
  end

  # defp filter_parens_reactions(molecule, reactions) do
  #   parens_starts = reactions.parens |> Map.keys()
  #   (0..(length(molecule) - 2))
  #   |> Enum.reduce(molecule, fn i, acc ->
  #     start_atom = Enum.at(molecule, i)
  #     case Map.get(parens, start_atom.name) do
  #       {parens_ends, not_parens_ends} ->
  #         molecule
  #         |> Enum.slice((i + 1)..-1)
  #         |> Enum.with_index(i + 1)
  #         |> Enum.reduce_while([], fn {maybe_paren_end, j}, mid_atoms ->
  #           cond do
  #             maybe_paren_end.name in not_parens_ends -> {:halt, acc}
  #             maybe_paren_end.name in parens_ends ->
  #               start_reactions = start_atom.reactions
  #               end_reactions = maybe_paren_end.reactions

  #               new_molecule =
  #                 acc
  #                 |> List.replace_at(i, fn atom -> end)
  #                 |> List.replace_at(j, )
  #               {:halt, new_molecule}
  #             true -> {:cont, mid_atoms ++ [maybe_paren_end.name]}
  #           end
  #         end)
  #       nil -> acc
  #     end
  #   end)
  # end

end

# :observer.start
input = File.read!("input/19.txt")
# input = File.read!("input/help.txt")
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

# input
# |> Nineteen.part_one()
# |> IO.inspect()

input
|> Nineteen.part_two()
|> IO.inspect(limit: :infinity)
