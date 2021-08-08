extends Node

var db_ref
var db_path = "games"
var game_name = "default"
var player_id = 1
var in_game = false

var email = "cnnranderson@gmail.com"
var password = "password1$"

func _ready():
	Firebase.Auth.connect("login_succeeded", self, "_on_login_succeeded")
	Firebase.Auth.login_with_email_and_password(email, password)

func create_match(new_game: String):
	# Make sure a game doesn't exist
	for game in db_ref.get_data():
		if new_game == game:
			return false
	
	game_name = new_game
	player_id = 1
	db_ref.update("%s" % game_name, { 
		"p%d_checkin" % player_id : OS.get_unix_time(),
		"turn": 1
	})
	_update_db_ref("games/%s" % game_name)
	return true

func join_match(existing_game: String):
	# Make sure game exists and is waiting for a player
	var available = true
	var game_exists = false
	for game in db_ref.get_data():
		if existing_game == game:
			game_exists = true
			if not _is_match_available(existing_game):
				available = false
	
	if not game_exists or (game_exists and not available):
		return false
	
	game_name = existing_game
	player_id = 2
	_update_db_ref("games/%s" % game_name)
	return true

func _update_db_ref(path: String):
	db_path = path
	db_ref = Firebase.Database.get_database_reference(db_path)

func _is_match_available(game_name: String):
	if not db_ref.get_data().has(game_name) or typeof(db_ref.get_data()[game_name]) != TYPE_DICTIONARY:
		return false
	if !db_ref.get_data()[game_name].has("p1_checkin") or db_ref.get_data()[game_name].has("p2_checkin"):
		return false
	return true

func _on_login_succeeded(auth_token):
	_connect_to_database()

func _connect_to_database():
	_update_db_ref("games")
	db_ref.connect("new_data_update", self, "_on_new_update")
	db_ref.connect("patch_data_update", self, "_on_patch_update")

func _on_new_update(data):
	if db_path == "games":
		Events.emit_signal("new_matches")
	print("update")
	print(data)

func _on_patch_update(data):
	print("patch")
	print(data)

func check_in():
	if GameState.is_local: return
	db_ref.update("/", { "p%d_checkin" % player_id : OS.get_unix_time() })

func set_board():
	db_ref.update("/", { "p%d_board" % player_id : GameState.grid })

func get_matches():
	var matches = []
	for match_name in db_ref.get_data():
		if _is_match_available(match_name):
			matches.append(match_name)
	return matches
