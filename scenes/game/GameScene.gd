extends Node2D

var db_ref
var email = "cnnranderson@gmail.com"
var password = "password1$"

func _ready():
	Events.connect("ship_placed", self, "_on_ship_placed")
	

func _on_ship_placed():
	pass

func _on_Checkin_timeout():
	Session.check_in()
	$Checkin.start()
