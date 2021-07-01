tool
extends Area2D
class_name ShipGrid

enum GridItem {NONE, SHIP}

export var grid_size : Vector2 = Vector2(16, 16) setget set_grid_size
export var tile_size : Vector2 = Vector2(16, 16) setget set_tile_size

var pos = Vector2(0, 0)
var grid = []

func _ready():
	var shape = $Shape.shape as Shape2D
	shape.extents = grid_size / 2 * tile_size

func _update_grid():
	$Shape.shape.extents = grid_size / 2 * tile_size
	grid = []
	for i in range(grid_size.x):
		grid.append([])
		for j in range(grid_size.y):
			grid[i].append(GridItem.NONE)

func set_grid_size(value):
	grid_size = value
	_update_grid()
	update()

func set_tile_size(value):
	tile_size = value
	_update_grid()
	update()

func _draw():
	var grid_width = grid_size.x * tile_size.x
	var grid_height = grid_size.y * tile_size.y
	draw_rect(Rect2(-grid_width / 2, -grid_height / 2, grid_width, grid_height), Color.gray)
	draw_rect(Rect2(pos.x * tile_size.x, pos.y * tile_size.y, tile_size.x, tile_size.y), Color.white)

func _on_Grid_input_event(viewport, event, shape_idx):
	if event is InputEventMouse:
		pos = ((event.position - position) / tile_size).floor()
		update()
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if GameState.selected_ship:
				var loc = _grid_to_world(pos)
				var normal = _grid_normalize(pos)
				GameState.selected_ship.place(self, loc, normal)

func _grid_to_world(coord: Vector2):
	return position + (pos * tile_size) + (tile_size / 2)

func _grid_normalize(coord: Vector2):
	return coord + (grid_size / 2)
