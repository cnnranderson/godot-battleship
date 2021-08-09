extends Node2D

var prev_moves = []

func _ready():
	Events.connect("turn_state_changed", self, "_on_turn_state_changed")
	_create_opponent_grid()

func _create_opponent_grid():
	var orientation = 0
	for i in range(10):
		for j in range(10):
			
			pass

func act():
	var valid_target = false
	var attack
	while not valid_target:
		attack = Vector2(randi() % 10 - 5, randi() % 10 - 5)
		if not prev_moves.has(attack):
			valid_target = true
	
	Events.emit_signal("enemy_attacked", attack)
	print(attack)
	prev_moves.append(attack)

func _on_turn_state_changed(prev_state, state):
	if state == 3:
		$TurnTimer.start()

func _on_TurnTimer_timeout():
	act()
