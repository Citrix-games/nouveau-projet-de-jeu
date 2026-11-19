extends CharacterBody2D

@export var speed: float = 200.0
var inventaire: Dictionary = {}

# Les recettes : nom de l'objet -> ressources nécessaires
var recettes: Dictionary = {
	"planche": {"bois": 2},
	"hache": {"bois": 3, "pierre": 2},
}

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
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			fabriquer("planche")
		elif event.keycode == KEY_2:
			fabriquer("hache")

func recolter():
	for corps in zone_recolte.get_overlapping_bodies():
		if corps.is_in_group("ressource"):
			var nom_ressource = corps.recolter()
			var quantite = 1
			if nom_ressource == "bois" and inventaire.get("hache", 0) > 0:
				quantite = 2
			ajouter_objet(nom_ressource, quantite)
			return

func ajouter_objet(nom: String, quantite: int):
	inventaire[nom] = inventaire.get(nom, 0) + quantite
	afficher_inventaire()

func peut_fabriquer(nom: String) -> bool:
	for ressource in recettes[nom]:
		if inventaire.get(ressource, 0) < recettes[nom][ressource]:
			return false
	return true

func fabriquer(nom: String):
	if not peut_fabriquer(nom):
		print("Il manque des ressources pour : ", nom)
		return
	for ressource in recettes[nom]:
		inventaire[ressource] -= recettes[nom][ressource]
		if inventaire[ressource] == 0:
			inventaire.erase(ressource)
	ajouter_objet(nom, 1)

func afficher_inventaire():
	var texte = ""
	for nom in inventaire:
		texte += nom + " : " + str(inventaire[nom]) + "\n"
	if texte == "":
		texte = "Inventaire vide\n"
	texte += "\n--- Craft ---\n[1] planche : 2 bois\n[2] hache : 3 bois + 2 pierre"
	label_bois.text = texte