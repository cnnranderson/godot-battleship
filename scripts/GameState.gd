extends Node

var ships_locked = false
var turn_state = -1 setget set_turn_state
var opponent_ready = true
var selected_ship : Ship
var is_local_game = false

var grid : Array = []
var hit_markers : Array = []
var enemy_grid : Array = []

func set_turn_state(new_value: int):
	Events.emit_signal("turn_state_changed", turn_state, new_value)
	turn_state = new_value

func reset():
	ships_locked = false
	turn_state = -1
	opponent_ready = false
	is_local_game = false
	grid.clear()
	hit_markers.clear()
	enemy_grid.clear()
	
