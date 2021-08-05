extends Node

var games_ref
var game_ref
var game_name = "test"
var player_id = 1
var in_game = true

var email = "cnnranderson@gmail.com"
var password = "password1$"

func _ready():
	Firebase.Auth.connect("login_succeeded", self, "_on_login_succeeded")
	Firebase.Auth.login_with_email_and_password(email, password)

func create_match(name: String):
	game_name = name
	player_id = 1

func join_match(name: String):
	game_name = name
	player_id = 2

func _on_login_succeeded(auth_token):
	connect_to_database()

func connect_to_database():
	games_ref = Firebase.Database.get_database_reference("games")
	games_ref.connect("new_data_update", self, "_on_new_update")
	games_ref.connect("patch_data_update", self, "_on_patch_update")

func _on_new_update(data):
	print("update")
	print(data)

func _on_patch_update(data):
	print("patch")
	print(data)

func check_in():
	games_ref.update("%s" % game_name, { "p%d_board" % player_id : GameState.grid[0][0] })
	games_ref.update("%s" % game_name, { "p%d_checkin" % player_id : OS.get_unix_time() })
	pass

func set_board():
	games_ref.update("%s" % game_name, { "p%d_board" % player_id : GameState.grid })
