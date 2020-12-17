defmodule TwentyOne do
  @weapons [
    {8, 4, 0},
    {10, 5, 0},
    {25, 6, 0},
    {40, 7, 0},
    {74, 8, 0}
  ]
  @armor [
    {13, 0, 1},
    {31, 0, 2},
    {53, 0, 3},
    {75, 0, 4},
    {102, 0, 5},
    # armor optional
    {0, 0, 0}
  ]
  @rings [
    {25, 1, 0},
    {50, 2, 0},
    {100, 3, 0},
    {20, 0, 1},
    {40, 0, 2},
    {80, 0, 3},
    # 0-2 rings
    {0, 0, 0},
    {0, 0, 0}
  ]
  @base_player %{hp: 100, damage: 0, armor: 0, spent: 0}

  def part_one(input) do
    boss = parse(input)

    equipment_possibilities(@base_player)
    |> Enum.map(fn player ->
      case fight(player, boss) do
        {:victory, hero, _} -> hero.spent
        # atoms always sort as greater than integers
        {:defeat, _, _} -> :defeat
      end
    end)
    |> Enum.min()
  end

  def part_two(input) do
    boss = parse(input)

    equipment_possibilities(@base_player)
    |> Enum.map(fn player ->
      case fight(player, boss) do
        {:victory, _, _} -> 0
        {:defeat, corpse, _} -> corpse.spent
      end
    end)
    |> Enum.max()
  end

  defp parse(text) do
    [[hp], [dmg], [armr]] = Regex.scan(~r/(\d+)/, text, capture: :all_but_first)
    %{
      hp: String.to_integer(hp),
      damage: String.to_integer(dmg),
      armor: String.to_integer(armr)
    }
  end

  defp equipment_possibilities(player) do
    for weapon <- @weapons,
        armor <- @armor,
        ring_1 <- @rings,
        ring_2 <- @rings -- [ring_1] do
      [weapon, armor, ring_1, ring_2]
      |> Enum.reduce(player, fn {gold, atk, armr}, acc ->
        acc
        |> Map.update!(:damage, &(&1 + atk))
        |> Map.update!(:armor, &(&1 + armr))
        |> Map.update!(:spent, &(&1 + gold))
      end)
    end
  end

  defp fight(player, boss), do: fight(player, boss, :player)
  defp fight(%{hp: hp} = player, boss, :player) when hp <= 0, do: {:defeat, player, boss}
  defp fight(player, %{hp: hp} = boss, :boss) when hp <= 0, do: {:victory, player, boss}
  defp fight(player, boss, :player) do
    damage_dealt = max(1, player.damage - boss.armor)
    fight(player, %{boss | hp: boss.hp - damage_dealt}, :boss)
  end
  defp fight(player, boss, :boss) do
    damage_dealt = max(1, boss.damage - player.armor)
    fight(%{player | hp: player.hp - damage_dealt}, boss, :player)
  end
end

input = File.read!("input/21.txt")

input
|> TwentyOne.part_one()
|> IO.inspect()

input
|> TwentyOne.part_two()
|> IO.inspect()
