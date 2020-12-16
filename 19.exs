defmodule Nineteen do
  def part_one(input) do
    {reactions, medicine} = parse(input)

    MapSet.new([medicine])
    |> step_possibilities(reactions)
    |> MapSet.size()
  end

  def part_two(input) do
    {reactions_list, medicine} = parse(input)

    elements_that_matter = parse_parens(reactions_list)

    e_output_length =
      Enum.find_value(reactions_list, fn
        {"e", out} -> length(out)
        _ -> nil
      end)

    simple_medicine = Enum.map(medicine, &convert_simple(&1, elements_that_matter))

    simple_reactions =
      reactions_list
      |> Enum.map(fn {inp, out} ->
        simple_out = Enum.map(out, &convert_simple(&1, elements_that_matter))
        {convert_simple(inp, elements_that_matter), simple_out}
      end)
      |> MapSet.new()

    Stream.iterate(simple_medicine, &revert(&1, simple_reactions))
    |> Enum.find_index(&(length(&1) == e_output_length))
    |> Kernel.+(1)
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

  ## part 1, full of recursive hopes and dreams

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

  ## part 2, after ~500 lines and multiple days of wandering in the deep dark recursive bog
  ## (check the commit history!)

  # this was function is a vestige of my part 2 failures
  # its ugliness is my family heirloom
  defp parse_parens(list) do
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
        [a, b]
      end
    parens =
      parens_candidates
      |> Enum.filter(fn [a, b] ->
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
      |> List.flatten()
      |> MapSet.new()

    parens
  end

  defp convert_simple(element, elements_that_matter) do
    if element in elements_that_matter, do: element, else: :el
  end

  defp revert(past \\ [], [head | rest] = molecule, reactions) do
    reaction = Enum.find(reactions, fn {_, out} -> List.starts_with?(molecule, out) end)
    case reaction do
      nil -> revert(past ++ [head], rest, reactions)
      {inp, out} -> past ++ [inp] ++ Enum.slice(rest, (length(out) - 1)..-1)
    end
  end
end

input = File.read!("input/19.txt")

input
|> Nineteen.part_one()
|> IO.inspect()

input
|> Nineteen.part_two()
|> IO.inspect()
