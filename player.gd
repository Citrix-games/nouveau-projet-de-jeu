extends CharacterBody2D

@export var speed: float = 200.0
var inventaire: Dictionary = {}

@onready var zone_recolte = $ZoneRecolte
@onready var label_bois = $CanvasLayer/LabelBois

func _ready():
	afficher_inventaire()

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()

func _unhandled_input(event):
	if event.is_action_pressed("interagir"):
		recolter()

func recolter():
	for corps in zone_recolte.get_overlapping_bodies():
		if corps.is_in_group("ressource"):
			var nom_ressource = corps.recolter()
			ajouter_objet(nom_ressource, 1)
			return

func ajouter_objet(nom: String, quantite: int):
	inventaire[nom] = inventaire.get(nom, 0) + quantite
	afficher_inventaire()

func afficher_inventaire():
	var texte = ""
	for nom in inventaire:
		texte += nom + " : " + str(inventaire[nom]) + "\n"
	if texte == "":
		texte = "Inventaire vide"
	label_bois.text = texte