extends CharacterBody2D

const SCENE_MUR = preload("res://mur.tscn")
const TAILLE_GRILLE = 64

@export var speed: float = 200.0
var inventaire: Dictionary = {}
var direction_regard: Vector2 = Vector2.DOWN
var murs_poses: Array = []

# Les recettes : nom de l'objet -> ressources nécessaires
var recettes: Dictionary = {
	"planche": {"bois": 2},
	"hache": {"bois": 3, "pierre": 2},
}

@onready var zone_recolte = $ZoneRecolte
@onready var label_bois = $CanvasLayer/LabelBois
@onready var indicateur = $Indicateur

func _ready():
	afficher_inventaire()

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		direction_regard = direction.normalized()
	velocity = direction * speed
	move_and_slide()
	mettre_a_jour_indicateur()

func _unhandled_input(event):
	if event.is_action_pressed("interagir"):
		recolter()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			fabriquer("planche")
		elif event.keycode == KEY_2:
			fabriquer("hache")
		elif event.keycode == KEY_B:
			poser_mur()

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

func calculer_position_mur() -> Vector2:
	return (global_position + direction_regard * 140).snapped(Vector2(TAILLE_GRILLE, TAILLE_GRILLE))

func peut_poser_mur() -> bool:
	var cible = calculer_position_mur()
	return inventaire.get("planche", 0) >= 1 and not (cible in murs_poses)

func mettre_a_jour_indicateur():
	indicateur.global_position = calculer_position_mur()
	if peut_poser_mur():
		indicateur.modulate = Color(0.3, 1.0, 0.3, 0.5)
	else:
		indicateur.modulate = Color(1.0, 0.3, 0.3, 0.5)

func poser_mur():
	if not peut_poser_mur():
		print("Impossible de poser un mur ici")
		return
	var position_mur = calculer_position_mur()
	var mur = SCENE_MUR.instantiate()
	get_parent().add_child(mur)
	mur.global_position = position_mur
	murs_poses.append(position_mur)
	inventaire["planche"] -= 1
	if inventaire["planche"] == 0:
		inventaire.erase("planche")
	afficher_inventaire()

func afficher_inventaire():
	var texte = ""
	for nom in inventaire:
		texte += nom + " : " + str(inventaire[nom]) + "\n"
	if texte == "":
		texte = "Inventaire vide\n"
	texte += "\n--- Craft ---\n[1] planche : 2 bois\n[2] hache : 3 bois + 2 pierre"
	texte += "\n[B] poser un mur : 1 planche"
	label_bois.text = texte
