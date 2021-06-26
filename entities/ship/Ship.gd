extends Node2D
class_name Ship

export(Vector2) var grid_pos = Vector2.ZERO
export(int, 0, 5) var hp = 5

var selected = false

func _ready():
	pass

func _process(delta):
	if selected:
		position = lerp(position, get_global_mouse_position(), 0.3)

func _on_Area2D_mouse_entered():
	material.set_shader_param("intensity", 400)

func _on_Area2D_mouse_exited():
	if selected: return
	material.set_shader_param("intensity", 0)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			selected = !selected
			GameState.selected_ship = self if selected else null
		
		if event.button_index == BUTTON_RIGHT:
			if selected:
				rotate(PI / 2)
