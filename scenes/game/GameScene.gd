extends Node2D

func _ready():
	Events.connect("ship_placed", self, "_on_ship_placed")
	Session.check_in()

func _on_ship_placed():
	pass

func _on_Checkin_timeout():
	Session.check_in()
	$Checkin.start()
