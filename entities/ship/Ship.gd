extends Node2D
class_name Ship

enum Orientation {VERTICAL, HORIZONTAL}

export(Vector2) var grid_pos = Vector2.ZERO
export(int, 0, 5) var hp = 5

onready var start_pos = position
onready var placed_pos = position

var dragging = false
var placed = false
var orientation = Orientation.HORIZONTAL

func _ready():
	pass

func _process(delta):
	if dragging:
		var target = _adjust_position(get_viewport().get_mouse_position())
		position = lerp(position, target, 0.3)
	elif not dragging and not placed:
		position = lerp(position, start_pos, 0.1)
	elif placed:
		position = lerp(position, placed_pos, 0.1)

func place(grid: ShipGrid, location: Vector2, grid_pos: Vector2):
	placed_pos = location
	placed = true
	var diff = Vector2(0, 0)
	match orientation:
		Orientation.HORIZONTAL:
			if grid_pos.x < 2:
				diff.x = -(grid_pos.x - int(hp / 2.0)) * 16
			elif grid_pos.x > grid.grid_size.x - 3:
				diff.x = (grid.grid_size.x - grid_pos.x - int((hp + 1) / 2.0)) * 16
		Orientation.VERTICAL:
			if grid_pos.y < 2:
				diff.y = -(grid_pos.y - int(hp / 2.0)) * 16
			elif grid_pos.y > grid.grid_size.y - 3:
				diff.y = (grid.grid_size.y - grid_pos.y - int((hp + 1) / 2.0)) * 16
				
	diff = _adjust_position(diff)
	placed_pos += diff

func _adjust_position(target: Vector2):
	if hp % 2 == 0:
		match orientation:
			Orientation.HORIZONTAL:
				target.x -= 8
			Orientation.VERTICAL:
				target.y -= 8
	return target

func _on_Area2D_mouse_entered():
	material.set_shader_param("intensity", 400)

func _on_Area2D_mouse_exited():
	if dragging: return
	material.set_shader_param("intensity", 0)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			dragging = !dragging
			if dragging:
				placed = false
				modulate.a = 0.9
			else:
				modulate.a = 1.0
		elif event.button_index == BUTTON_LEFT and not event.pressed:
			GameState.selected_ship = self if dragging else null
		
		if event.button_index == BUTTON_RIGHT and event.pressed:
			if dragging:
				orientation = Orientation.HORIZONTAL if orientation == Orientation.VERTICAL else Orientation.VERTICAL
				rotation = 0 if orientation == Orientation.HORIZONTAL else (PI / 2)
