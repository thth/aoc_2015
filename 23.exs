defmodule TwentyThree do
  def part_one(input) do
    instructions = parse(input)

    %{a: 0, b: 0, i: 0}
    |> run(instructions)
    |> Map.get(:b)
  end

  def part_two(input) do
    instructions = parse(input)

    %{a: 1, b: 0, i: 0}
    |> run(instructions)
    |> Map.get(:b)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(fn line ->
      case String.split(line, " ") do
        ["hlf", r] -> {:hlf, String.to_atom(r)}
        ["tpl", r] -> {:tpl, String.to_atom(r)}
        ["inc", r] -> {:inc, String.to_atom(r)}
        ["jmp", off] -> {:jmp, String.to_integer(off)}
        ["jie", <<r::binary-size(1), _>>, off] -> {:jie, String.to_atom(r), String.to_integer(off)}
        ["jio", <<r::binary-size(1), _>>, off] -> {:jio, String.to_atom(r), String.to_integer(off)}
      end
    end)
    |> Enum.with_index()
    |> Enum.map(fn {ins, i} -> {i, ins} end)
    |> Enum.into(%{})
  end

  defp run(state, instructions) do
    case Map.get(instructions, state.i) do
      nil -> state
      ins ->
        new_state = run_ins(ins, state)
        run(new_state, instructions)
    end
  end

  defp run_ins({:hlf, r}, state) do
    state
    |> Map.update!(r, &div(&1, 2))
    |> Map.update!(:i, &(&1 + 1))
  end

  defp run_ins({:tpl, r}, state) do
    state
    |> Map.update!(r, &(&1 * 3))
    |> Map.update!(:i, &(&1 + 1))
  end

  defp run_ins({:inc, r}, state) do
    state
    |> Map.update!(r, &(&1 + 1))
    |> Map.update!(:i, &(&1 + 1))
  end

  defp run_ins({:jmp, off}, state) do
    Map.update!(state, :i, &(&1 + off))
  end

  defp run_ins({:jie, r, off}, state) do
    if rem(Map.get(state, r), 2) == 0 do
      Map.update!(state, :i, &(&1 + off))
    else
      Map.update!(state, :i, &(&1 + 1))
    end
  end

  defp run_ins({:jio, r, off}, state) do
    if Map.get(state, r) == 1 do
      Map.update!(state, :i, &(&1 + off))
    else
      Map.update!(state, :i, &(&1 + 1))
    end
  end
end

input = File.read!("input/23.txt")

input
|> TwentyThree.part_one()
|> IO.inspect()

input
|> TwentyThree.part_two()
|> IO.inspect()
