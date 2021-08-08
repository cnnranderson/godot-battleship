extends Node2D

onready var state_label : Label = $GameUI/HUD/StateLabel

var ships_placed = []

func _ready():
	Events.connect("ships_locked", self, "_on_ships_locked")
	Events.connect("enemy_ships_locked", self, "_on_enemy_ships_locked")
	Events.connect("turn_state_changed", self, "_on_turn_state_changed")
	#Session.check_in()

func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		GameState.turn_state = randi() % 5
	if GameState.turn_state == 0:
			#review_player_grid()
		if Input.is_action_just_pressed("ui_up"):
			review_attack_grid()

func review_player_grid():
	$Camera.position = Vector2.ZERO

func review_attack_grid():
	$Camera.position = Vector2(0, -360)

func _on_Checkin_timeout():
	Session.check_in()
	$Timers/Checkin.start()

func _on_LockGrid_pressed():
	# Short Circuit if all ships not placed
	var ships = $Player/Ships
	for ship in ships.get_children():
		if ship is Ship and not ship.placed:
			return
	
	$Player/PlayerUI/LockGrid.visible = false
	GameState.ships_locked = true
	GameState.turn_state = 1

func _on_turn_state_changed(state):
	var state_text = ""
	match state:
		0: state_text = "Place your ships!"
		1: state_text = "Get ready!"
		2: state_text = "Your turn to Attack!"
		3: state_text = "Opponents turn - Watch out!"
		4: state_text = "Your turn to Attack!"
	$GameUI/StateTransition/TransitionLabel.text = state_text
	
	# Tween Transition screen effects
	$GameUI/StateTransition.modulate.a = 1.0
	$Tween.interpolate_property($GameUI/StateTransition, "rect_position:x", -500, 0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($GameUI/StateTransition, "modulate:a", 1, 0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN, 2.0)
	$Tween.interpolate_property($GameUI/StateTransition, "rect_position:x", -500, -500, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 2.5)
	
	# Tween HUD state label
	$Tween.interpolate_property($GameUI/HUD/StateLabel, "modulate:a", 1, 0, 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_callback($GameUI/HUD/StateLabel, 1, "set_text", state_text)
	$Tween.interpolate_property($GameUI/HUD/StateLabel, "modulate:a", 0, 1, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN, 2)
	
	$Tween.start()
