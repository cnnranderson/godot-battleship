extends Node2D
class_name AI

var difficulty = Global.Difficulty.IMPOSSIBLE
var memory = {}

func _ready():
	Events.connect("turn_state_changed", self, "_on_turn_state_changed")
	_create_opponent_grid()

func _create_opponent_grid():
	var orientation = 0
	GameState.enemy_grid = [
		[2, 2, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	]

func act():
	var attack
	match difficulty:
		Global.Difficulty.EASY: attack = easy()
		Global.Difficulty.MEDIUM: attack = medium()
		Global.Difficulty.HARD: attack = hard()
		Global.Difficulty.IMPOSSIBLE: attack = impossible()
	
	Events.emit_signal("enemy_attacked", attack)
	var attack_loc = GameState.grid[attack.y][attack.x]
	if attack_loc > 0:
		if not memory.has(attack_loc): memory[attack_loc] = []
		memory[attack_loc].append(attack)
			

# Attack randomly
func easy():
	return _find_random_hit()

# Attack with very minor precision (20%). No memory.
func medium():
	if Helpers.chance_luck(20):
		return _find_guaranteed_hit()
	else:
		return _find_random_hit()
	
# Attack with reasonable precision (35%). Has understanding of hit ships. (60% chance to hit a ship again)
func hard():
	if Helpers.chance_luck(40):
		if Helpers.chance_luck(70):
			var list
			for i in memory.keys():
				if memory[i].size() != i:
					list.append(i)
			list.shuffle()
			if list.size() > 0:
				return _find_guaranteed_hit(memory[list[0]])
		return _find_guaranteed_hit()
	return _find_random_hit()

# Attack with unexplainable accuracy (60%). Has awareness of hit ships. (85% chance to hit a ship again)
func impossible():
	if Helpers.chance_luck(65):
		if Helpers.chance_luck(85):
			var list = []
			for i in memory.keys():
				if memory[i].size() != i:
					list.append(i)
			list.shuffle()
			if list.size() > 0:
				return _find_guaranteed_hit(memory[list[0]])
		return _find_guaranteed_hit()
	return _find_random_hit()

func _find_guaranteed_hit(ship_type = -1):
	print("Guaranteed")
	var valid_target = false
	var attack = Vector2(randi() % 10, randi() % 10)
	var dir = -1 if randi() % 2 == 0 else 1
	while not valid_target:
		for i in range(attack.y, 10 if dir == 1 else 0, dir):
			for j in range(attack.x, 10 if dir == 1 else 0, dir):
				attack = Vector2(j, i)
				if GameState.grid[attack.y][attack.x] > 0 and (ship_type == -1 or ship_type == GameState.grid[attack.y][attack.x]):
					return attack
			attack.x = 0 if dir == 1 else 9
		attack = Vector2(0 if dir == 1 else 9, 0 if dir == 1 else 9)

func _find_random_hit():
	print("Not guaranteed")
	var valid_target = false
	var attack
	while not valid_target:
		attack = Vector2(randi() % 10, randi() % 10)
		if GameState.grid[attack.y][attack.x] >= 0:
				valid_target = true
	return attack

func _on_turn_state_changed(prev_state, state):
	if state == 3:
		$TurnTimer.start()

func _on_TurnTimer_timeout():
	act()
