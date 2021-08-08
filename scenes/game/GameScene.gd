extends Node2D

onready var state_label : Label = $GameUI/HUD/StateLabel

var ships_placed = []

func _ready():
	Events.connect("ships_locked", self, "_on_ships_locked")
	Events.connect("enemy_ships_locked", self, "_on_enemy_ships_locked")
	Events.connect("turn_state_changed", self, "_on_turn_state_changed")
	if GameState.is_local_game:
		GameState.turn_state = 0
	else:
		GameState.turn_state = -1
	#Session.check_in()

func _process(delta):
	# Allow player to review game boards if it's their turn to attack
	if GameState.turn_state == 2 or GameState.turn_state == 0:
		if Input.is_action_just_pressed("ui_down"):
			review_player_grid()
		if Input.is_action_just_pressed("ui_up"):
			review_attack_grid()

func review_player_grid():
	$Camera.position = Vector2.ZERO

func review_attack_grid():
	$Camera.position = Vector2(0, -360)

func center_board():
	$Tween.interpolate_property($Player/Board, "position:x", 0, 40, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func _on_Checkin_timeout():
	Session.check_in()
	$Timers/Checkin.start()

func _on_LockGrid_pressed():
	# Short Circuit if all ships not placed
	var ships = $Player/Board/Ships
	for ship in ships.get_children():
		if ship is Ship and not ship.placed:
			return
	
	$Player/PlayerUI/LockGrid.visible = false
	center_board()
	GameState.ships_locked = true
	GameState.turn_state = 3 if Session.player_id == 2 else 2 if GameState.opponent_ready else 1

func _on_turn_state_changed(state):
	var state_text = ""
	var transition_text = ""
	match state:
		-1:
			state_text = "Waiting for opponent..."
			transition_text = state_text
		0: 
			state_text = "Place your ships!"
			transition_text = state_text
			review_player_grid()
		1: 
			state_text = "Waiting for opponent to finish..."
			transition_text = "Get ready!"
		2: 
			state_text = "Your turn to Attack!"
			transition_text = "Make your move!"
			review_attack_grid()
		3: 
			state_text = "Waiting for opponent to attack..."
			transition_text = "Opponent's turn - Watch out!"
			review_player_grid()
	$GameUI/StateTransition/TransitionLabel.text = transition_text
	
	# Tween Transition screen effects
	$GameUI/StateTransition.modulate.a = 1.0
	$Tween.interpolate_property($GameUI/StateTransition, "rect_position:x", -500, 0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if GameState.turn_state != -1:
		$Tween.interpolate_property($GameUI/StateTransition, "modulate:a", 1, 0, 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN, 2)
		$Tween.interpolate_callback($GameUI/StateTransition, 2.3, "_set_position", Vector2(-500, 0))
	
		# Tween HUD state label
		$Tween.interpolate_property($GameUI/HUD/StatePanel, "rect_position:y", 0, -20, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.interpolate_callback($GameUI/HUD/StatePanel/StateLabel, 1, "set_text", state_text)
		$Tween.interpolate_property($GameUI/HUD/StatePanel, "rect_position:y", -20, 0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, 2)
	
	$Tween.start()

func _on_FireButton_pressed():
	
	pass
