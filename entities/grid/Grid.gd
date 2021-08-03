extends Node2D
class_name ShipGrid

export var grid_size : Vector2 = Vector2(16, 16) setget set_grid_size
export var tile_size : Vector2 = Vector2(16, 16) setget set_tile_size

onready var area_shape = $Area2D/Shape

var pos = Vector2(0, 0)
var hovering = false

func _ready():
	set_meta("entity_type", "grid")
	
	$Area2D.connect("mouse_entered", self, "_on_mouse_over", [true])
	$Area2D.connect("mouse_exited", self, "_on_mouse_over", [false])
	Events.connect("ship_picked_up", self, "_on_ship_picked_up")
	
	area_shape.shape.extents = grid_size / 2 * tile_size
	GameState.grid = []
	for i in range(grid_size.x):
		GameState.grid.append([])
		for _j in range(grid_size.y):
			GameState.grid[i].append(0)

func _update_grid():
	$Border.rect_position.x = -(grid_size.x / 2 * tile_size.x + 3)
	$Border.rect_position.y = -(grid_size.y / 2 * tile_size.y + 3)
	$Border.rect_size.x = grid_size.x * tile_size.x + 6
	$Border.rect_size.y = grid_size.y * tile_size.y + 6
	$Water.material.set_shader_param("tile", Vector2(grid_size.x * 4, grid_size.y * 4))
	$Water.rect_position = -grid_size / 2 * tile_size
	$Water.rect_size = grid_size * tile_size
	area_shape.shape.extents = grid_size / 2 * tile_size

func set_grid_size(value):
	grid_size = value
	_update_grid()

func set_tile_size(value):
	tile_size = value
	_update_grid()

func _grid_to_world(coord: Vector2):
	return position + (coord * tile_size) + (tile_size / 2)

func _grid_normalize(coord: Vector2):
	return coord + (grid_size / 2)

func _scale(value):
	return value * tile_size.x

func _process(_delta):
	update()

func _draw():
	for i in range(0, 16):
		for j in range(0, 16):
			if GameState.grid[i][j] != 0:
				draw_rect(Rect2(_scale(i - 8), _scale(j - 8), tile_size.x, tile_size.y), Color(20 * GameState.grid[i][j]))
				
	if hovering and GameState.selected_ship:
		var co = Color.black if GameState.grid[pos.x - 8][pos.y - 8] == 0 else Color.red
		var ship_hp = GameState.selected_ship.hp
		if GameState.selected_ship.orientation == 1:
			draw_rect(Rect2(_scale(max(-8, min(pos.x - ship_hp / 2, 8 - ship_hp))), _scale(pos.y), _scale(ship_hp), tile_size.y), co)
		else:
			draw_rect(Rect2(_scale(pos.x), _scale(max(-8, min(pos.y - ship_hp / 2, 8 - ship_hp))), tile_size.x, _scale(ship_hp)), co)

func place_ship(ship):
	var min_x = pos.x
	var min_y = pos.y
	var ship_overlap = false
	if GameState.selected_ship.orientation == 1:
		min_x = max(-8, min(pos.x - ship.hp / 2, 8 - ship.hp))
		for i in range(min_x + 8, min_x + ship.hp + 8):
			if GameState.grid[i][pos.y + 8] != 0:
				ship_overlap = true
	else:
		min_y = max(-8, min(pos.y - ship.hp / 2, 8 - ship.hp))
		for i in range(min_y + 8, min_y + ship.hp + 8):
			if GameState.grid[pos.x + 8][i] != 0:
				ship_overlap = true
	
	if ship_overlap:
		return false
	else:
		if GameState.selected_ship.orientation == 1:
			for i in range(min_x + 8, min_x + ship.hp + 8):
				GameState.grid[i][pos.y + 8] = ship.hp
		else:
			for i in range(min_y + 8, min_y + ship.hp + 8):
				GameState.grid[pos.x + 8][i] = ship.hp
	
	var loc = _grid_to_world(pos)
	var normal = _grid_normalize(pos)
	GameState.selected_ship.place(self, loc, normal)
	return true

func _on_mouse_over(over):
	hovering = over

func _on_ship_picked_up(ship):
	for i in range(0, 16):
		for j in range(0, 16):
			if GameState.grid[i][j] == ship.hp:
				GameState.grid[i][j] = 0

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse:
		pos = ((event.position - position) / tile_size).floor()
