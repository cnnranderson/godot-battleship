extends Node2D

const AI = preload("res://entities/ai/AI.tscn")

onready var state_label : Label = $GameUI/HUD/StatePanel/StateLabel

var ships_placed = []
var next_state = 0

func _ready():
	Events.connect("ships_locked", self, "_on_ships_locked")
	Events.connect("enemy_ships_locked", self, "_on_enemy_ships_locked")
	Events.connect("turn_state_changed", self, "_on_turn_state_changed")
	Events.connect("enemy_attacked", self, "_on_enemy_attacked")
	Events.connect("player_joined", self, "_on_player_joined")
	Events.connect("player_disconnected", self, "_on_player_disconnected")
	
	if GameState.is_local_game:
		GameState.turn_state = 0
		var opponent = AI.instance()
		add_child(opponent)
	else:
		GameState.turn_state = -1
	Session.check_in()

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

func attempt_attack(grid_obj : ShipGrid, target, is_opponent_attack):
	print("Attempting attack: ", target, " by %s" % ("Enemy" if is_opponent_attack else "Player"))
	var grid = GameState.enemy_grid if not is_opponent_attack else GameState.grid
	if grid[target.y][target.x] > 0 and (grid_obj.selected or is_opponent_attack):
		print("Hit")
		grid_obj.place_hit_marker(grid_obj.attack_pos, true)
		grid[target.y][target.x] = -grid[target.y][target.x]
		if grid_obj.check_grid_lost(grid):
			GameState.turn_state = 6
		else:
			GameState.turn_state = 4
	else:
		print("Miss")
		grid_obj.place_hit_marker(grid_obj.attack_pos, false)
		grid[target.y][target.x] = -1
		GameState.turn_state = 5

func show_overlay(transition_text, future_state):
	$Timers/StateTimer.start()
	next_state = future_state

func _on_Checkin_timeout():
	Session.check_in()
	$Timers/Checkin.start()

func _on_LockGrid_pressed():
	# Short Circuit if all ships not placed
	var ships = $Player/Board/Ships
	for ship in ships.get_children():
		if ship is Ship and not ship.placed and ship.visible:
			return
	
	center_board()
	$Player/PlayerUI/LockGrid.visible = false
	Session.set_board()
	GameState.ships_locked = true
	GameState.turn_state = 1 if not GameState.opponent_ready else (3 if Session.player_id == 2 else 2)

func _on_turn_state_changed(prev_state, state):
	var state_text = $GameUI/HUD/StatePanel/StateLabel.text
	var transition_text = $GameUI/StateTransition/TransitionLabel.text
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
		4:
			state_text = "..."
			transition_text = "DIRECT HIT!" if prev_state == 2 else "YOU WERE HIT!"
			next_state = 3 if prev_state == 2 else 2
			$Timers/StateTimer.start()
		5:
			state_text = "..."
			transition_text = "ATTACK MISSED" if prev_state == 2 else "THE OPPONENT MISSED!!"
			next_state = 3 if prev_state == 2 else 2
			$Timers/StateTimer.start()
		6:
			state_text = "..."
			transition_text = "You LOST" if prev_state == 3 else "You WON!!"
			$GameUI/StateTransition/MainMenu.visible = true
		7:
			state_text = "..."
			transition_text = "A player has disconnected..."
			$GameUI/StateTransition/MainMenu.visible = true
	
	$GameUI/StateTransition/TransitionLabel.text = transition_text
	
	# Tween Transition screen effects
	$GameUI/StateTransition.modulate.a = 1.0
	$Tween.interpolate_property($GameUI/StateTransition, "rect_position:x", -500, 0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	# Make sure to only display state progress when the match has begun (i.e. 2nd player is available)
	if state != -1 and state < 6:
		$Tween.interpolate_property($GameUI/StateTransition, "modulate:a", 1, 0, 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN, 2)
		$Tween.interpolate_callback($GameUI/StateTransition, 2.3, "_set_position", Vector2(-500, 0))
	
		# Tween HUD state label
		$Tween.interpolate_property($GameUI/HUD/StatePanel, "rect_position:y", 0, -20, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.interpolate_callback($GameUI/HUD/StatePanel/StateLabel, 1, "set_text", state_text)
		$Tween.interpolate_property($GameUI/HUD/StatePanel, "rect_position:y", -20, 0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, 2)
	
	$Tween.start()

func _on_StateTimer_timeout():
	GameState.turn_state = next_state

func _on_FireButton_pressed():
	var target = $Attack/Grid.attack_pos + Vector2.ONE * 5
	if GameState.turn_state != 2: return
	
	# Make sure there's a valid target
	if target == -Vector2.ONE or GameState.hit_markers.has(target) or not $Attack/Grid.selected:
		$Tween.interpolate_property($Attack/AttackUI/NoTargetLabel, "modulate:a", 0, 1, 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.interpolate_property($Attack/AttackUI/NoTargetLabel, "rect_position:y", 315, 305, 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.interpolate_property($Attack/AttackUI/NoTargetLabel, "modulate:a", 1, 0, 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN, 1)
		$Tween.interpolate_property($Attack/AttackUI/NoTargetLabel, "rect_position:y", 305, 315, 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN, 1)
		$Tween.start()
	else:
		GameState.hit_markers.append(target)
		attempt_attack($Attack/Grid, target, false)
		Session.attack(target)

func _on_enemy_attacked(pos):
	$Player/Board/Grid.attack_pos = pos - Vector2.ONE * 5
	var target = pos
	attempt_attack($Player/Board/Grid, target, true)

func _on_MainMenu_pressed():
	GameState.reset()
	Global.main.load_scene(Global.Scenes.LOBBY)

func _on_player_joined():
	GameState.opponent_joined = true
	GameState.turn_state = 0

func _on_enemy_ships_locked():
	GameState.opponent_ready = true
	if GameState.turn_state == 1:
		GameState.turn_state = 3 if Session.player_id == 2 else 2 if GameState.opponent_ready else 1

func _on_player_disconnected():
	GameState.turn_state = 7
