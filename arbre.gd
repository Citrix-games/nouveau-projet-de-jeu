extends StaticBody2D

@export var vie: int = 3

func _ready():
	add_to_group("arbre")

func recolter() -> int:
	vie -= 1
	if vie <= 0:
		queue_free()
	return 1
