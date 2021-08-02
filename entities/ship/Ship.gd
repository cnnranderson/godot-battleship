extends Node2D
class_name Ship

enum Orientation {VERTICAL, HORIZONTAL}

export(int, 0, 5) var hp = 5

onready var start_pos = position
onready var target_pos = position

var dragging = false
var placed = false
var orientation = Orientation.HORIZONTAL
var rot = rotation

func _ready():
	set_meta("entity_type", "ship")

func _process(delta):
	if dragging:
		target_pos = _adjust_position(get_viewport().get_mouse_position())
	
	position = lerp(position, target_pos, 0.4)
	rotation = lerp(rotation, rot, 0.5)

func place(grid: ShipGrid, location: Vector2, grid_pos: Vector2):
	z_index = 0
	modulate.a = 1.0
	placed = true
	target_pos = location
	var diff = Vector2(0, 0)
	match orientation:
		Orientation.HORIZONTAL:
			if grid_pos.x < 2:
				diff.x = -(grid_pos.x - int(hp / 2.0)) * 16
			elif grid_pos.x > grid.grid_size.x - 3:
				diff.x = min((grid.grid_size.x - grid_pos.x - int((hp + 1) / 2.0)) * 16, 0)
		Orientation.VERTICAL:
			if grid_pos.y < 2:
				diff.y = -(grid_pos.y - int(hp / 2.0)) * 16
			elif grid_pos.y > grid.grid_size.y - 3:
				diff.y = min((grid.grid_size.y - grid_pos.y - int((hp + 1) / 2.0)) * 16, 0)
				
	diff = _adjust_position(diff)
	target_pos += diff
	GameState.selected_ship = null

func _adjust_position(target: Vector2):
	if hp % 2 == 0:
		match orientation:
			Orientation.HORIZONTAL:
				target.x -= 8
			Orientation.VERTICAL:
				target.y -= 8
	return target

func _on_Area2D_mouse_entered():
	if GameState.selected_ship == null or GameState.selected_ship == self:
		material.set_shader_param("intensity", 400)

func _on_Area2D_mouse_exited():
	if dragging: return
	material.set_shader_param("intensity", 0)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			# Ignore input if a different ship is already being dragged around
			if GameState.selected_ship != self and GameState.selected_ship != null:
				return
				
			# Enable/disable dragging
			dragging = !dragging
			
			if dragging:
				modulate.a = 0.9
				z_index = 1
				placed = false
				GameState.selected_ship = self
			else:
				var grid_overlap = null
				var ship_overlap = null
				for area in $Area2D.get_overlapping_areas():
					match area.get_parent().get_meta("entity_type"):
						"ship":
							print("Found ship")
							ship_overlap = area.get_parent() as Ship
						"grid":
							print("Found grid")
							grid_overlap = area.get_parent() as ShipGrid
				
				if ship_overlap:
					dragging = true
				elif grid_overlap:
					grid_overlap.place_ship(self)
				else:
					z_index = 0
					target_pos = start_pos
					GameState.selected_ship = null
		
		if event.button_index == BUTTON_RIGHT and event.pressed:
			if dragging:
				orientation = Orientation.HORIZONTAL if orientation == Orientation.VERTICAL else Orientation.VERTICAL
				rot = 0 if orientation == Orientation.HORIZONTAL else (PI / 2)
