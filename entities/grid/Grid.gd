extends Area2D

export(Vector2) var grid_size = Vector2(16, 16)
export(int) var tile_size = 16

var pos = Vector2(0, 0)

func _ready():
	var shape = $Shape.shape as Shape2D
	pass

func _process(delta):
	update()

func _draw():
	var grid_width = grid_size.x * tile_size
	var grid_height = grid_size.y * tile_size
	draw_rect(Rect2(-grid_width / 2, -grid_height / 2, grid_width, grid_height), Color.black)
	draw_rect(Rect2(pos.x * tile_size, pos.y * tile_size, tile_size, tile_size), Color.white)

func _on_Grid_input_event(viewport, event, shape_idx):
	if event is InputEventMouse:
		pos = ((event.position - position) / tile_size).floor()
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if GameState.selected_ship:
				var loc = Vector2(position.x + pos.x * tile_size + tile_size / 2, position.y + pos.y * tile_size + tile_size / 2)
				var normal = _grid_normalize(pos)
				GameState.selected_ship.place(loc, normal)

func _grid_to_world(coord: Vector2):
	return position + pos * tile_size

func _grid_normalize(coord: Vector2):
	return coord + grid_size / 2
