extends Control

func _ready():
	$LobbyDialog.popup()
	$LobbyDialog/VBox/Create.connect("button_down", self, "_on_Create_pressed")
	$LobbyDialog/VBox/Join.connect("button_down", self, "_on_Join_pressed")

func _on_Create_pressed():
	if Session.create_match("test3"):
		Global.main.load_scene(Global.Scenes.GAME)
	else:
		print("Match name already exists")

func _on_Join_pressed():
	$LobbyDialog.visible = false
	Global.main.load_scene(Global.Scenes.GAME)
