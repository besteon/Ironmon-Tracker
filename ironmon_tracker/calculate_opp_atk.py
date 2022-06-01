def calculate_damage(level, atk, deff, move_pow,*, STAB_bool, weak_2x=False, weak_4x=False):
    STAB = 1
    if STAB_bool:
        STAB = 1.5
    weak = 1
    if weak_2x:
        weak = 2
    if weak_4x:
        weak = 4
    RNG = 1

    level_modifier = (2*level + 10) / 250
    atk_def = atk / deff
    modifiers = STAB * weak * RNG



    damage = (level_modifier * atk_def * move_pow +2) * modifiers

    return damage


def calculate_atk(level, damage, deff, move_pow,*, STAB_bool, weak_2x=False, weak_4x=False):
    """Returns the two possibles extremes atk stats.
        """
    STAB = 1
    if STAB_bool:
        STAB = 1.5
    weak = 1
    if weak_2x:
        weak = 2
    if weak_4x:
        weak = 4


    possible_values = []
    for RNG in [1, 0.85]:
        modifiers = STAB * weak * RNG

        level_modifier = (2*level + 10) / 250
        possible_values.append(int((damage / modifiers - 2) / move_pow / level_modifier * deff))
        
    return possible_values


# Scenario EXAMPLE:
    # https://aminoapps.com/c/nintendo_gen7/page/blog/pokemon-damage-formula-part-2/wK7D_bdWfoup5WBvzB7qg4WR7Ve3nWE1EblCw

# Mismagius
    # Recieves 29 damage (loses 29 HP)
    # Has 303 special defense
    # Gets attacked by a water gun  (move power = 40) from a wailmer lvl 100
        # STAB boost!

calculate_atk(100, 29, 303, 40, STAB_bool=True)
# Returns [156, 187]    <==== This means that Wailmer has a value that can be between 156 and 187.