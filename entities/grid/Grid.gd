extends Node2D
class_name ShipGrid

const HitMarker = preload("res://entities/hitmarker/HitMarker.tscn")

export var grid_size = 10
export var tile_size = 16

onready var area_shape = $Area2D/Shape

var pos = Vector2(0, 0)
var hovering = false

func _ready():
	set_meta("entity_type", "grid")
	$Area2D.connect("mouse_entered", self, "_on_mouse_over", [true])
	$Area2D.connect("mouse_exited", self, "_on_mouse_over", [false])
	Events.connect("ship_picked_up", self, "_on_ship_picked_up")
	
	area_shape.shape.extents = Vector2.ONE * (grid_size / 2 * tile_size)
	GameState.grid = []
	for i in range(grid_size):
		GameState.grid.append([])
		for _j in range(grid_size):
			GameState.grid[i].append(0)

func _grid_to_world(coord: Vector2):
	return position + (coord * tile_size) + Vector2.ONE * (tile_size / 2)

func _grid_normalize(coord: Vector2):
	return coord + Vector2.ONE * (grid_size / 2)

func _scale(value):
	return value * tile_size

func _process(_delta):
	#update()
	pass

func _draw():
	#for i in range(0, 16):
	#	for j in range(0, 16):
	#		if GameState.grid[i][j] != 0:
	#			draw_rect(Rect2(_scale(i - 8), _scale(j - 8), tile_size.x, tile_size.y), Color(20 * GameState.grid[i][j]))
	#			
	#if hovering and GameState.selected_ship:
	#	var co = Color.black if GameState.grid[pos.x - 8][pos.y - 8] == 0 else Color.red
	#	var ship_hp = GameState.selected_ship.hp
	#	if GameState.selected_ship.orientation == 1:
	#		draw_rect(Rect2(_scale(max(-8, min(pos.x - ship_hp / 2, 8 - ship_hp))), _scale(pos.y), _scale(ship_hp), tile_size.y), co)
	#	else:
	#		draw_rect(Rect2(_scale(pos.x), _scale(max(-8, min(pos.y - ship_hp / 2, 8 - ship_hp))), tile_size.x, _scale(ship_hp)), co)
	pass

func place_ship(ship):
	var min_x = pos.x
	var min_y = pos.y
	var ship_overlap = false
	if GameState.selected_ship.orientation == 1:
		min_x = max(-grid_size / 2, min(pos.x - ship.hp / 2, grid_size / 2 - ship.hp))
		for i in range(min_x + grid_size / 2, min_x + ship.hp + grid_size / 2):
			if GameState.grid[i][pos.y + grid_size / 2] != 0:
				ship_overlap = true
	else:
		min_y = max(-8, min(pos.y - ship.hp / 2, grid_size / 2 - ship.hp))
		for i in range(min_y + grid_size / 2, min_y + ship.hp + grid_size / 2):
			if GameState.grid[pos.x + grid_size / 2][i] != 0:
				ship_overlap = true
	
	if ship_overlap:
		return false
	else:
		if GameState.selected_ship.orientation == 1:
			for i in range(min_x + grid_size / 2, min_x + ship.hp + grid_size / 2):
				GameState.grid[i][pos.y + grid_size / 2] = ship.hp
		else:
			for i in range(min_y + grid_size / 2, min_y + ship.hp + grid_size / 2):
				GameState.grid[pos.x + grid_size / 2][i] = ship.hp
	
	var loc = _grid_to_world(pos)
	var normal = _grid_normalize(pos)
	GameState.selected_ship.place(self, loc, normal)
	return true

func place_hit_marker(pos):
	pass

func place_attack_marker(pos):
	pass

func _on_mouse_over(over):
	hovering = over

func _on_ship_picked_up(ship):
	for i in range(0, grid_size):
		for j in range(0, grid_size):
			if GameState.grid[i][j] == ship.hp:
				GameState.grid[i][j] = 0

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse:
		pos = ((event.position - position) / tile_size).floor()
