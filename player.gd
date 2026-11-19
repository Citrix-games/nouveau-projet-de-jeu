extends CharacterBody2D

@export var speed: float = 200.0
var bois: int = 0

@onready var zone_recolte = $ZoneRecolte
@onready var label_bois = $CanvasLayer/LabelBois

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()

func _unhandled_input(event):
	if event.is_action_pressed("interagir"):
		print("E pressé")
		recolter()

func recolter():
	var corps_proches = zone_recolte.get_overlapping_bodies()
	print("Objets dans la zone : ", corps_proches.size())
	for corps in corps_proches:
		if corps.is_in_group("arbre"):
			bois += corps.recolter()
			label_bois.text = "Bois : " + str(bois)
			return