tool
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
	area_shape.shape.extents = grid_size / 2 * tile_size

func _update_grid():
	area_shape.shape.extents = grid_size / 2 * tile_size
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
				GameState.grid[i].append(0)

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

func _scale(value):
	return value * tile_size.x

func _process(delta):
	update()

func _draw():
	if hovering and GameState.selected_ship:
		var ship_hp = GameState.selected_ship.hp
		if GameState.selected_ship.orientation == 1:
			draw_rect(Rect2(_scale(max(-8, min(pos.x - ship_hp / 2, 8 - ship_hp))), _scale(pos.y), _scale(ship_hp), tile_size.y), Color.black)
		else:
			draw_rect(Rect2(_scale(pos.x), _scale(max(-8, min(pos.y - ship_hp / 2, 8 - ship_hp))), tile_size.x, _scale(ship_hp)), Color.black)

func place_ship(ship):
	print("Placing")
	var loc = _grid_to_world(pos)
	var normal = _grid_normalize(pos)
	GameState.selected_ship.place(self, loc, normal)

func _on_mouse_over(over):
	hovering = over

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouse:
		pos = ((event.position - position) / tile_size).floor()
