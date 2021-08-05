extends Control

onready var name_field = $NewGamePanel/VBox/GameName
onready var match_list = $MatchList/VBox/MBox/List
onready var tween = $Tween

func _ready():
	$MatchList.rect_position.y = 400

func _valid_game_name():
	return not name_field.text.strip_edges().empty()

func _join_match(game_name: String):
	if Session.join_match(game_name):
		Global.main.load_scene(Global.Scenes.GAME)
	else:
		print("Match unjoinable")

func _on_Create_pressed():
	if _valid_game_name():
		if Session.create_match(name_field.text.strip_edges()):
			Global.main.load_scene(Global.Scenes.GAME)
		else:
			print("Match name already exists")
	else:
		print("Invalid match name")

func _on_Join_pressed():
	match_list.clear()
	for match_name in Session.get_matches():
		match_list.add_item(match_name)
	
	tween.interpolate_property($MatchList, "rect_position:y", 400, 70, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func _on_JoinMatch_pressed():
	if match_list.is_anything_selected():
		var match_name = match_list.get_item_text(match_list.get_selected_items()[0])
		print("Joining match: ", match_name)
		_join_match(match_name)

func _on_Back_pressed():
	tween.interpolate_property($MatchList, "rect_position:y", 70, 400, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()

func _on_Refresh_pressed():
	match_list.clear()
	for match_name in Session.get_matches():
		match_list.add_item(match_name)
