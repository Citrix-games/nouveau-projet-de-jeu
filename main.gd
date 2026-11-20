extends Node2D

const SCENE_ARBRE = preload("res://arbre.tscn")
const SCENE_ROCHER = preload("res://rocher.tscn")
const SCENE_BUISSON = preload("res://buisson.tscn")

@export var graine: int = 0
@export var demi_taille_carte: float = 1900.0
@export var zone_depart: float = 300.0
@export var distance_min: float = 90.0

@export var nb_forets: int = 8
@export var arbres_par_foret: int = 15
@export var rayon_foret: float = 300.0

@export var nb_amas_pierre: int = 5
@export var pierres_par_amas: int = 6
@export var rayon_amas: float = 150.0
@export var nb_buissons: int = 6
@export var baies_par_groupe: int = 4
@export var rayon_buissons: float = 120.0

var rng = RandomNumberGenerator.new()
var positions_occupees: Array = []

func _ready():
	if graine == 0:
		rng.randomize()
	else:
		rng.seed = graine
	generer_groupes(SCENE_ARBRE, nb_forets, arbres_par_foret, rayon_foret)
	generer_groupes(SCENE_ROCHER, nb_amas_pierre, pierres_par_amas, rayon_amas)
	generer_groupes(SCENE_BUISSON, nb_buissons, baies_par_groupe, rayon_buissons)

func generer_groupes(scene: PackedScene, nb_groupes: int, objets_par_groupe: int, rayon: float):
	for i in nb_groupes:
		var centre = Vector2(
			rng.randf_range(-demi_taille_carte, demi_taille_carte),
			rng.randf_range(-demi_taille_carte, demi_taille_carte)
		)
		for j in objets_par_groupe:
			placer_objet(scene, centre, rayon)

func placer_objet(scene: PackedScene, centre: Vector2, rayon: float):
	for essai in 10:
		var decalage = Vector2.from_angle(rng.randf_range(0.0, TAU)) * rng.randf_range(0.0, rayon)
		var pos = centre + decalage
		if position_valide(pos):
			var objet = scene.instantiate()
			objet.position = pos
			add_child(objet)
			positions_occupees.append(pos)
			return

func position_valide(pos: Vector2) -> bool:
	if absf(pos.x) > demi_taille_carte or absf(pos.y) > demi_taille_carte:
		return false
	if pos.length() < zone_depart:
		return false
	for autre in positions_occupees:
		if pos.distance_to(autre) < distance_min:
			return false
	return true
