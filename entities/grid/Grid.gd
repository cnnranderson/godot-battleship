tool
extends Area2D
class_name ShipGrid

enum GridItem {NONE, SHIP, MISS}

export var grid_size : Vector2 = Vector2(16, 16) setget set_grid_size
export var tile_size : Vector2 = Vector2(16, 16) setget set_tile_size

var pos = Vector2(0, 0)
var mouse_inside = false

func _ready():
	$Shape.shape.extents = grid_size / 2 * tile_size

func _update_grid():
	$Shape.shape.extents = grid_size / 2 * tile_size
	$Border.rect_position.x = -(grid_size.x / 2 * tile_size.x + 3)
	$Border.rect_position.y = -(grid_size.y / 2 * tile_size.y + 3)
	$Border.rect_size.x = grid_size.x * tile_size.x + 6
	$Border.rect_size.y = grid_size.y * tile_size.y + 6
	$Water.material.set_shader_param("tile", Vector2(grid_size.x * 4, grid_size.y * 4))
	$Water.rect_position = -grid_size / 2 * tile_size
	$Water.rect_size = grid_size * tile_size
	
	if not Engine.editor_hint:
		GameState.grid = []
		for i in range(grid_size.x):
			GameState.grid.append([])
			for j in range(grid_size.y):
				GameState.grid[i].append(GridItem.NONE)

func set_grid_size(value):
	grid_size = value
	_update_grid()

func set_tile_size(value):
	tile_size = value
	_update_grid()

func _grid_to_world(coord: Vector2):
	return position + (pos * tile_size) + (tile_size / 2)

func _grid_normalize(coord: Vector2):
	return coord + (grid_size / 2)

func _process(delta):
	update()

func _draw():
	if mouse_inside:
		draw_rect(Rect2(pos.x * tile_size.x, pos.y * tile_size.y, tile_size.x, tile_size.y), Color.black)

func _on_Grid_input_event(viewport, event, shape_idx):
	if event is InputEventMouse:
		pos = ((event.position - position) / tile_size).floor()
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if GameState.selected_ship:
				var loc = _grid_to_world(pos)
				var normal = _grid_normalize(pos)
				GameState.selected_ship.place(self, loc, normal)

func _on_Grid_mouse_entered():
	mouse_inside = true

func _on_Grid_mouse_exited():
	mouse_inside = false
