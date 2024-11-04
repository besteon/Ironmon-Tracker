- BATTLE DOC
Check after each frame if an action has to be done:
- On entering battle: Battle.inActiveBattle is true but BotUtils.inBattle is false
	- BotUtils.inBattle = true
	- Define strategy:
		- In case of a wild battle there are 4 options:
			- It is the first battle (lab fight): KILL
			- The foe pokemon is a shiny: KILL
			- The pokemon has a high score and we're in the capture sequence (after Rival 1 and before first trainer or before Rival 1 with a ball on the 2 starting items): CAPTURE
			The score is determined by:
				- Checking the BST of the foe.
				- Checking the foe moves and calculating their move score. We want to know at least 3/4 moves.
				- Checking the ability if it is known after learning 3/4 moves. For that we need to list a few wanted abilities / unwanted abilities and score them.
				- Checking the type and the effectiveness table of the foe.
				- Calculating roughly the ATK/SPA of the foe's attacks with the damage received.
				- If rough calculations indicate that one of our own mon's moves will only inflict up to 40% of the foe's remaining HP, we can use this attack to make CAPTURE chance higher and roughly calculate foe's DEF/SPD.
					- Beware of critical hits / misses in calculations. If there's a crit we need to divide the result by crit coefficient. Misses are ignored.
			- Every other possibility: RUN
		- In case of a trainer battle: always KILL
	- Skip intro text. Intro text can be longer because of an ability (ex Intimidation/Drizzle...). Better to mash B so there's no risk of selecting a wrong option
- On new turn (1st turn = 0, starting our counter at -1 so the first turn is actually a new turn)
	- Define the action to take according to the current strategy
	- If KILL:
		- Check our mon's health and determine if its health is critical (simply a HP percentage might be enough). Check the probability of our mon's speed to be higher than foe speed (from foe BST, but being safe). If we already know (already played a turn against this foe mon) no need to estimate it. If our mon is faster, check the probability of OHKO of the foe. If this probability is enough, no need to heal. If not (our mon is slower or won't OHKO the for), check for a good healing item (near restoring 100% HP, but no need to have 100% either)
		- If healed, action = BAG + Items/Berries + healing_item_id
		- Check our mon's status. If sleeping/frozen, check for a healing item. If poisoned/burned/paralyzed/confused, check the number of pokemon the trainer has left and if the foe can be defeated quickly. If it's the last pokemon and it can be defeated quickly, no need to heal. If not, check for a healing item. If poisoned, also check for the remaining health needed (for example need at least 50 HP, it is a really safe value). In dungeons, just heal the poison/burn/paralysis unless it's the last battle of the dungeon.
		- If healed, action = BAG + Items/Berries + healing_item_id
		- Check the best move to use according to its score (pretty much the damage that will be inflicted). It can also be interesting to boost the mon (+ATK/SPA/DEF/SPD). Boost moves should have a specific degressive score so they are only used in the beginning of a battle to setup the mon. + Check all the specific moves



