extends Node2D

var db_ref
var email = "cnnranderson@gmail.com"
var password = "password1$"

func _ready():
	Firebase.Auth.connect("login_succeeded", self, "_on_login_succeeded")
	Firebase.Auth.login_with_email_and_password(email, password)
	Events.connect("ship_placed", self, "_on_ship_placed")
	
func _on_login_succeeded(auth_token):
	connect_to_database()
	
func connect_to_database():
	db_ref = Firebase.Database.get_database_reference("1")
	db_ref.connect("new_data_update", self, "on_new_update")
	db_ref.connect("patch_data_update", self, "on_patch_update")
	db_ref.update("/", { "test" : "12345" })

func on_new_update(data):
	print("new data")

func on_patch_update(data):
	print("data updated")
	
func on_data_delete(data):
	print("deleted")

func _on_ship_placed():
	db_ref.update("/", { "test" : randi() % 20 })
	pass
