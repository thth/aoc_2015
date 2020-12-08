defmodule Fourteen do
  defmodule Deer do
    defstruct [:name, :speed, :duration, :rest,
      state: {:fly, 0}, distance: 0, points: 0]
  end

  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&calculate_distance_after(&1, 2503))
    |> Enum.max_by(fn {_name, distance} -> distance end)
    |> elem(1)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.into(%{}, fn {name, spd, dur, rst} ->
      {name, %Deer{name: name, speed: spd, duration: dur, rest: rst}}
    end)
    |> Stream.iterate(&simulate_second/1)
    |> Enum.at(2503)
    |> Enum.max_by(fn {_name, deer} -> deer.points end)
    |> elem(1)
    |> Map.get(:points)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(fn line ->
      regex = ~r/^(\w+).+ (\d+) .+ (\d+) .+ (\d+) /
      [name, speed, duration, rest] = Regex.run(regex, line, capture: :all_but_first)
      {
        name,
        String.to_integer(speed),
        String.to_integer(duration),
        String.to_integer(rest)
      }
    end)
  end

  defp calculate_distance_after({name, speed, duration, rest}, time) do
    distance =
      div(time, duration + rest) *
      (speed * duration) +
      (speed *
        min(
          rem(time, duration + rest),
          duration
        )
      )
    {name, distance}
  end

  defp simulate_second(state) do
    state
    |> Enum.map(fn {name, deer} -> {name, simulate_deer(deer)} end)
    |> Enum.into(%{})
    |> award_point()
  end

  defp simulate_deer(%Deer{state: {:fly, s}} = deer) when s >= deer.duration,
    do: %Deer{deer | state: {:rest, 1}}
  defp simulate_deer(%Deer{state: {:fly, s}} = deer),
    do: %Deer{deer | state: {:fly, s + 1}, distance: deer.distance + deer.speed}
  defp simulate_deer(%Deer{state: {:rest, s}} = deer) when s >= deer.rest,
    do: %Deer{deer | state: {:fly, 1}, distance: deer.distance + deer.speed}
  defp simulate_deer(%Deer{state: {:rest, s}} = deer),
    do: %Deer{deer | state: {:rest, s + 1}}

  defp award_point(state) do
    {_, %Deer{distance: distance}} =
      Enum.max_by(state, fn {_name, deer} -> deer.distance end)

    leaders =
      state
      |> Enum.filter(fn {_name, deer} -> deer.distance == distance end)
      |> Enum.map(&elem(&1, 0))

    Enum.reduce(leaders, state, fn leader, acc ->    
      Map.update!(acc, leader, fn %Deer{points: points} = deer ->
        %Deer{deer | points: points + 1}
      end)
    end)
  end
end

input = File.read!("input/14.txt")

input
|> Fourteen.part_one()
|> IO.inspect()

input
|> Fourteen.part_two()
|> IO.inspect()
