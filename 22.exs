defmodule TwentyTwo do
  defmodule State do
    defstruct wizard: nil, boss: nil, turn: :wizard, effects: [], status: :cont, hard?: false
  end

  @base_wizard %{hp: 50, mp: 500, shield: 0, mp_spent: 0}

  def part_one(input) do
    boss = parse(input)
    min_mana_fight(@base_wizard, boss)
  end

  def part_two(input) do
    boss = parse(input)
    min_mana_fight(%State{wizard: @base_wizard, boss: boss, hard?: true})
  end

  defp parse(text) do
    [[hp], [dmg]] = Regex.scan(~r/\d+/, text)
    %{
      hp: String.to_integer(hp),
      damage: String.to_integer(dmg)
    }
  end

  defp min_mana_fight(wizard, boss) do
    initial_state = %State{wizard: wizard, boss: boss}
    resolve_states([initial_state])
  end

  defp min_mana_fight(%State{} = state) do
    resolve_states([state])
  end

  defp resolve_states(to_resolve, min_mana \\ nil)
  defp resolve_states([], min_mana), do: min_mana
  defp resolve_states([head | rest], min_mana) do
    if head.wizard.mp_spent >= min_mana do
      resolve_states(rest, min_mana)
    else
      case step_turn(head) do
        {:halt, end_state} ->
          case end_state.status do
            :victory -> resolve_states(rest, min(end_state.wizard.mp_spent, min_mana))
            :defeat -> resolve_states(rest, min_mana)
          end
        {:cont, next_states} -> resolve_states(next_states ++ rest, min_mana)
      end
    end
  end

  defp step_turn(state) do
    case state.status do
      :cont ->
        case run_turn(state) do
          states when is_list(states) -> {:cont, states}
          %State{status: :cont} = cont -> {:cont, [cont]}
          halted -> {:halt, halted}
        end
      _status -> {:halt, state}
    end
  end

  defp run_turn(state) do
    state
    |> do_turn(:hard_mode)
    |> do_turn(:poison)
    |> do_turn(:recharge)
    |> do_turn(:shield)
    |> do_turn(:act)
  end

  defp do_turn(%State{status: status} = state, _action)
    when status in ~w[victory defeat]a, do: state
  defp do_turn(%State{boss: %{hp: boss_hp}} = state, _action) when boss_hp <= 0,
    do: %State{state | status: :victory}
  defp do_turn(%State{wizard: %{hp: wizard_hp}} = state, _action) when wizard_hp <= 0,
    do: %State{state | status: :defeat}

  defp do_turn(%State{hard?: true, turn: :wizard} = state, :hard_mode) do
    %State{state |
      wizard: %{state.wizard |
        hp: state.wizard.hp - 1
      }
    }
  end
  defp do_turn(state, :hard_mode), do: state

  defp do_turn(state, :poison) do
    case List.keyfind(state.effects, :poison, 0) do
      nil -> state
      {:poison, n} ->
        new_effects =
          case n do
            1 -> List.keydelete(state.effects, :poison, 0)
            n -> List.keyreplace(state.effects, :poison, 0, {:poison, n - 1})
          end
        %State{state |
          boss: %{state.boss | hp: state.boss.hp - 3},
          effects: new_effects
        }
    end
  end
  defp do_turn(state, :recharge) do
    case List.keyfind(state.effects, :recharge, 0) do
      nil -> state
      {:recharge, n} ->
        new_effects =
          case n do
            1 -> List.keydelete(state.effects, :recharge, 0)
            n -> List.keyreplace(state.effects, :recharge, 0, {:recharge, n - 1})
          end
        %State{state |
          wizard: %{state.wizard | mp: state.wizard.mp + 101},
          effects: new_effects
        }
    end
  end
  defp do_turn(state, :shield) do
    case List.keyfind(state.effects, :shield, 0) do
      nil ->
        %State{state |
          wizard: %{state.wizard | shield: 0}
        }
      {:shield, n} ->
        new_effects =
          case n do
            1 -> List.keydelete(state.effects, :shield, 0)
            n -> List.keyreplace(state.effects, :shield, 0, {:shield, n - 1})
          end
        %State{state |
          wizard: %{state.wizard | shield: 7},
          effects: new_effects
        }
    end
  end
  defp do_turn(%State{turn: :boss} = state, :act) do
    %State{state |
      wizard: %{state.wizard |
        hp: state.wizard.hp - max(1, state.boss.damage - state.wizard.shield)
      },
      turn: :wizard
    }
  end
  defp do_turn(%State{turn: :wizard} = state, :act) do
    possible_spells =
      [{53, :missile}, {73, :drain}, {113, :shield}, {173, :poison}, {229, :recharge}]
      |> Enum.filter(fn {mana, _} -> state.wizard.mp >= mana end)
      |> Enum.filter(fn {_, spell} ->
        current_effects = state.effects |> Enum.map(fn {effect, _} -> effect end)
        spell not in current_effects
      end)

    case possible_spells do
      [] ->
        %State{state | status: :defeat}
      possible_spells ->
        Enum.map(possible_spells, fn spell -> wizard_act(state, spell) end)
    end
  end

  defp wizard_act(state, {cost, :missile}) do
    %State{state |
      wizard: %{state.wizard |
        mp: state.wizard.mp - cost,
        mp_spent: state.wizard.mp_spent + cost,
      },
      boss: %{state.boss |
        hp: state.boss.hp - 4
      },
      turn: :boss
    }
  end
  defp wizard_act(state, {cost, :drain}) do
    %State{state |
      wizard: %{state.wizard |
        hp: state.wizard.hp + 2,
        mp: state.wizard.mp - cost,
        mp_spent: state.wizard.mp_spent + cost,
      },
      boss: %{state.boss |
        hp: state.boss.hp - 2
      },
      turn: :boss
    }
  end
  defp wizard_act(state, {cost, :shield}) do
    %State{state |
      wizard: %{state.wizard |
        mp: state.wizard.mp - cost,
        mp_spent: state.wizard.mp_spent + cost,
      },
      effects: [{:shield, 6} | state.effects],
      turn: :boss
    }
  end
  defp wizard_act(state, {cost, :poison}) do
    %State{state |
      wizard: %{state.wizard |
        mp: state.wizard.mp - cost,
        mp_spent: state.wizard.mp_spent + cost,
      },
      effects: [{:poison, 6} | state.effects],
      turn: :boss
    }
  end
  defp wizard_act(state, {cost, :recharge}) do
    %State{state |
      wizard: %{state.wizard |
        mp: state.wizard.mp - cost,
        mp_spent: state.wizard.mp_spent + cost,
      },
      effects: [{:recharge, 5} | state.effects],
      turn: :boss
    }
  end
end

input = File.read!("input/22.txt")

input
|> TwentyTwo.part_one()
|> IO.inspect()

input
|> TwentyTwo.part_two()
|> IO.inspect()
