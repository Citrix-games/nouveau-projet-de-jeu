extends CanvasModulate

# Durée d'une journée complète (24 h de jeu), en secondes réelles
@export var duree_jour: float = 120.0
# Heure de jeu au lancement (8.0 = 8 h du matin)
@export var heure_depart: float = 8.0
# Le jour dure de l'heure de lever à l'heure de coucher
@export var heure_lever: float = 6.0
@export var heure_coucher: float = 18.0
# Durée (en heures de jeu) de l'aube et du crépuscule
@export var duree_transition: float = 2.0

@export var couleur_nuit: Color = Color(0.15, 0.18, 0.4)
@export var couleur_aube: Color = Color(1.0, 0.65, 0.55)
@export var couleur_jour: Color = Color(1.0, 1.0, 1.0)
@export var couleur_crepuscule: Color = Color(1.0, 0.55, 0.35)

var heure: float = 8.0

func _ready():
	heure = heure_depart
	add_to_group("cycle_jour_nuit")
	color = calculer_couleur()

func _process(delta):
	heure = fmod(heure + 24.0 * delta / duree_jour, 24.0)
	color = calculer_couleur()

func est_nuit() -> bool:
	return heure < heure_lever or heure >= heure_coucher

# Avancement (de 0 à 1, adouci) entre deux heures de jeu
func progression(debut: float, fin: float) -> float:
	return smoothstep(0.0, 1.0, inverse_lerp(debut, fin, heure))

func calculer_couleur() -> Color:
	var moitie = duree_transition / 2.0
	var debut_aube = heure_lever - moitie
	var fin_aube = heure_lever + moitie
	var debut_crepuscule = heure_coucher - moitie
	var fin_crepuscule = heure_coucher + moitie

	if heure < debut_aube or heure >= fin_crepuscule:
		return couleur_nuit
	elif heure < heure_lever:
		return couleur_nuit.lerp(couleur_aube, progression(debut_aube, heure_lever))
	elif heure < fin_aube:
		return couleur_aube.lerp(couleur_jour, progression(heure_lever, fin_aube))
	elif heure < debut_crepuscule:
		return couleur_jour
	elif heure < heure_coucher:
		return couleur_jour.lerp(couleur_crepuscule, progression(debut_crepuscule, heure_coucher))
	else:
		return couleur_crepuscule.lerp(couleur_nuit, progression(heure_coucher, fin_crepuscule))
