extends Node2D

var ships_placed = []

func _ready():
	Events.connect("ship_placed", self, "_on_ship_placed")
	Events.connect("ship_picked_up", self, "_on_ship_picked_up")
	Events.connect("ships_locked", self, "_on_ships_locked")
	Events.connect("enemy_ships_locked", self, "_on_enemy_ships_locked")
	Session.check_in()

func _process(delta):
	if GameState.turn_state == 0:
		if Input.is_action_pressed("ui_down"):
			review_player_grid()
		elif Input.is_action_pressed("ui_up"):
			review_attack_grid()

func review_player_grid():
	$Camera.position = Vector2.ZERO

func review_attack_grid():
	$Camera.position = Vector2(0, -360)

func _on_ship_placed(ship: Ship):
	if not ships_placed.has(ship):
		ships_placed.append(ship)

func _on_ship_picked_up(ship: Ship):
	if ships_placed.has(ship):
		ships_placed.remove(ships_placed.find(ship))

func _on_Checkin_timeout():
	Session.check_in()
	$Timers/Checkin.start()

func _on_LockGrid_pressed():
	if ships_placed.size() == 4:
		GameState.ships_locked = true
		GameState.turn_state = 1
		$Player/PlayerUI/LockGrid.visible = false
