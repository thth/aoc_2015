defmodule Seven do
  use Bitwise

  @bit16 65536

  def part_one(input) do
    input
    |> parse()
    |> run_commands()
    |> Map.get("a")
  end

  def part_two(input) do
    commands = parse(input)

    a = commands |> run_commands() |> Map.get("a")

    commands
    |> run_commands([], %{"b" => a})
    |> Map.get("a")
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&(&1 -- ["->"]))
    |> Enum.map(fn cmd ->
      Enum.map(cmd, fn part ->
        case Integer.parse(part) do
          {int, ""} -> int
          :error -> part
        end
      end)
    end)
  end

  defp run_commands(commands, wires \\ %{}), do: run_commands(commands, [], wires)
  
  defp run_commands([], [], wires), do: wires
  defp run_commands([], skipped, wires), do: run_commands(Enum.reverse(skipped), [], wires)
  defp run_commands([command | rest], skipped, wires) do
    case run_command(command, wires) do
      {:ok, new_wires} -> run_commands(rest, skipped, new_wires)
      :skipped -> run_commands(rest, [command | skipped], wires)
    end
  end

  defp run_command([bits, dest], wires) when is_integer(bits), do: {:ok, Map.put_new(wires, dest, bits)}
  defp run_command([a, dest], wires) when is_binary(a) do
    case value(wires, a) do
      nil -> :skipped
      bits -> {:ok, Map.put(wires, dest, bits)}
    end
  end

  defp run_command(["NOT", a, dest], wires) do
    case value(wires, a) do
      nil -> :skipped
      bits -> {:ok, Map.put(wires, dest, @bit16 + bnot(bits))}
    end
  end

  defp run_command([a, cmd, b, dest], wires) do
    case {value(wires, a), value(wires, b)} do
      {a_bits, b_bits} when not is_nil(a_bits) and not is_nil(b_bits) ->
        func =
          case cmd do
            "AND"    -> &band/2
            "OR"     -> &bor/2
            "LSHIFT" -> &bsl/2
            "RSHIFT" -> &bsr/2
          end
        {:ok, Map.put(wires, dest, func.(a_bits, b_bits))}
      _ ->
        :skipped
    end
  end

  defp value(_wires, n) when is_integer(n), do: n
  defp value(wires, label) when is_binary(label), do: Map.get(wires, label)
end

input = File.read!("input/07.txt")

input
|> Seven.part_one()
|> IO.inspect()

input
|> Seven.part_two()
|> IO.inspect()
