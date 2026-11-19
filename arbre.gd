extends StaticBody2D

@export var type_ressource: String = "bois"
@export var vie: int = 3

func _ready():
	add_to_group("ressource")

func recolter() -> String:
	vie -= 1
	if vie <= 0:
		queue_free()
	return type_ressource
