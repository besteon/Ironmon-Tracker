local function calculate_opponent_attack(damage, crit)
    --damage (int)
    -- crit (bool) TODO

    local level --level : Level of the opponent Monster.
    level = 100  -- For proof of concept. Let's fix this at 100.

    local defense -- defense : Defense of the attacked pokemon.
    defense = 303  -- For proof of the concept. LeT's fix this at 303.

    local move_power  -- Move's Power.
    move_power = 40  -- For proof of the concept. Water gun is used and has 40 powr.

    local STAB  -- STAB
    STAB = true  -- Wailmer used the move.

    local resistance --Resistance or weaknesses multiplier
    resistance = 1  -- We don,t resist, nor are weak to water. For proof of concept.

    local level_modifier = (2*level + 10) / 250



    local min_atk = (damage / STAB * resistance * 0.85 - 2) / move_power / level_modifier * defense
    local max_atk = (damage / STAB * resistance * 1 - 2) / move_power / level_modifier * defense
    return min_atk, max_atk

end
