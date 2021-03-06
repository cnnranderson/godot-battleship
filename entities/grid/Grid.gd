extends Node2D
class_name ShipGrid

const HitMarker = preload("res://entities/hitmarker/HitMarker.tscn")
enum GridType { PLAYER, ATTACK }

export var grid_size = 10
export var tile_size = 16
export(GridType) var grid_type = GridType.PLAYER

onready var area_shape = $Area2D/Shape

var pos = Vector2(0, 0)
var attack_pos = -Vector2.ONE
var hovering = false
var selected = false

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
	if grid_type == GridType.ATTACK and hovering and GameState.turn_state == 2:
		var target = attack_pos if selected else pos
		$Selection.position = lerp($Selection.position, target * tile_size, 0.2)

func place_ship(ship):
	var min_x = pos.x
	var min_y = pos.y
	var ship_overlap = false
	if GameState.selected_ship.orientation == 1:
		min_x = max(-grid_size / 2, min(pos.x - ship.hp / 2, grid_size / 2 - ship.hp))
		for i in range(min_x + grid_size / 2, min_x + ship.hp + grid_size / 2):
			if GameState.grid[pos.y + grid_size / 2][i] != 0:
				ship_overlap = true
	else:
		min_y = max(-8, min(pos.y - ship.hp / 2, grid_size / 2 - ship.hp))
		for i in range(min_y + grid_size / 2, min_y + ship.hp + grid_size / 2):
			if GameState.grid[i][pos.x + grid_size / 2] != 0:
				ship_overlap = true
	
	if ship_overlap:
		return false
	else:
		if GameState.selected_ship.orientation == 1:
			for i in range(min_x + grid_size / 2, min_x + ship.hp + grid_size / 2):
				GameState.grid[pos.y + grid_size / 2][i] = ship.hp
		else:
			for i in range(min_y + grid_size / 2, min_y + ship.hp + grid_size / 2):
				GameState.grid[i][pos.x + grid_size / 2] = ship.hp
	
	var loc = _grid_to_world(pos)
	var normal = _grid_normalize(pos)
	GameState.selected_ship.place(self, loc, normal)
	return true

func place_hit_marker(pos, did_hit):
	if did_hit:
		GameState.hit_markers.append(pos)
		var hit_mark = HitMarker.instance()
		hit_mark.position = pos * tile_size + Vector2.ONE * 8
		$HitMarkers.add_child(hit_mark)
		hit_mark.get_node("AnimationPlayer").play("Rotate")
	
	if !did_hit:
		GameState.hit_markers.append(pos)
		var hit_mark = HitMarker.instance()
		hit_mark.position = pos * tile_size + Vector2.ONE * 8
		$HitMarkers.add_child(hit_mark)
		hit_mark.get_node("AnimationPlayer").stop()
	
	# Reset hit marker
	selected = false
	attack_pos = -Vector2.ONE
	$Selection.visible = false

func select_attack():
	selected = true
	attack_pos = pos
	print("Targeting: ", attack_pos + Vector2.ONE * 5)

func check_grid_lost(grid):
	for i in range(0, grid_size):
		for j in range(0, grid_size):
			if grid[i][j] > 0:
				return false
	return true

func _on_mouse_over(over):
	hovering = over
	if grid_type == GridType.ATTACK and GameState.turn_state == 2:
		$Selection.visible = hovering if not selected else true

func _on_ship_picked_up(ship):
	for i in range(0, grid_size):
		for j in range(0, grid_size):
			if GameState.grid[i][j] == ship.hp:
				GameState.grid[i][j] = 0

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse:
		pos = ((get_global_mouse_position() - position) / tile_size).floor()
	
	if event is InputEventMouseButton and grid_type == GridType.ATTACK:
		if event.button_index == BUTTON_LEFT and event.pressed:
			select_attack()
