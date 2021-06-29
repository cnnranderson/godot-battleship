extends Node2D
class_name Ship

enum Orientation {VERTICAL, HORIZONTAL}

export(Vector2) var grid_pos = Vector2.ZERO
export(int, 0, 5) var hp = 5

onready var start_pos = position
onready var placed_pos = position

var selected = false
var placed = false
var orientation = Orientation.HORIZONTAL

func _ready():
	pass

func _process(delta):
	if selected:
		position = lerp(position, get_global_mouse_position(), 0.3)
	elif not selected and not placed:
		position = lerp(position, start_pos, 0.1)
	elif placed:
		position = lerp(position, placed_pos, 0.1)

func place(location: Vector2, grid_pos: Vector2):
	placed_pos = location
	placed = true
	match orientation:
		Orientation.HORIZONTAL:
			var diff = Vector2(0, 0)
			if grid_pos.x < 2:
				diff.x = (int(grid_pos.x) % 2 - int(hp / 2.0)) * 16
			elif grid_pos.x > 13:
				diff.x = -(15 - grid_pos.x - int(hp / 2.0)) * 16
			placed_pos -= diff
		Orientation.VERTICAL:
			var diff = Vector2(0, 0)
			if grid_pos.y < 2:
				diff.y = (int(grid_pos.y) % 2 - int(hp / 2.0)) * 16
			elif grid_pos.y > 13:
				diff.y = -(15 - grid_pos.y - int(hp / 2.0)) * 16
			placed_pos -= diff

func _on_Area2D_mouse_entered():
	material.set_shader_param("intensity", 400)

func _on_Area2D_mouse_exited():
	if selected: return
	material.set_shader_param("intensity", 0)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			selected = !selected
			if selected:
				placed = false
				modulate.a = 0.9
			else:
				modulate.a = 1.0
		elif event.button_index == BUTTON_LEFT and not event.pressed:
			GameState.selected_ship = self if selected else null
		
		if event.button_index == BUTTON_RIGHT and event.pressed:
			if selected:
				orientation = Orientation.HORIZONTAL if orientation == Orientation.VERTICAL else Orientation.VERTICAL
				rotate(PI / 2)
