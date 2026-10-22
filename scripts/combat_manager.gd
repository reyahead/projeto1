extends Node

enum EncounterState { EXPLORATION, COMBAT, ENDED }

const ENCOUNTER_DISTANCE := 165.0

var encounter_state := EncounterState.EXPLORATION
var enemies: Array[Node2D] = []
var enemy_bars: Dictionary = {}

@onready var player: CharacterBody2D = get_node("../Player")
@onready var player_combatant: Combatant = player.get_node("Combatant")
@onready var hud: CanvasLayer = get_node("../HUD")
@onready var player_hp: ProgressBar = get_node("../HUD/PlayerHP")
@onready var player_initiative: ProgressBar = get_node("../HUD/PlayerInitiative")
@onready var state_label: Label = get_node("../HUD/CombatState")

func _ready() -> void:
	hud.visible = false
	enemies.clear()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy is Node2D:
			continue
		enemies.append(enemy)
		var combatant: Combatant = enemy.get_node("Combatant")
		var hp_bar: ProgressBar = get_node("../HUD/%sHP" % enemy.name)
		var initiative_bar: ProgressBar = get_node("../HUD/%sInitiative" % enemy.name)
		enemy_bars[enemy] = {"hp": hp_bar, "initiative": initiative_bar}
		combatant.changed.connect(_update_hud)
		combatant.defeated.connect(_on_combatant_defeated)

	player_combatant.changed.connect(_update_hud)
	player_combatant.defeated.connect(_on_combatant_defeated)
	_update_hud()

func _process(_delta: float) -> void:
	if encounter_state == EncounterState.EXPLORATION:
		for enemy in enemies:
			if enemy.global_position.distance_to(player.global_position) <= ENCOUNTER_DISTANCE:
				_start_encounter()
				break
	elif encounter_state == EncounterState.COMBAT:
		if player_combatant.state == Combatant.State.DEAD or _all_enemies_defeated():
			_end_encounter()

func _start_encounter() -> void:
	encounter_state = EncounterState.COMBAT
	player_combatant.combat_enabled = true
	for enemy in enemies:
		var combatant: Combatant = enemy.get_node("Combatant")
		if combatant.state != Combatant.State.DEAD:
			combatant.combat_enabled = true
	hud.visible = true
	_update_hud()

func _end_encounter() -> void:
	encounter_state = EncounterState.ENDED
	player_combatant.combat_enabled = false
	for enemy in enemies:
		enemy.get_node("Combatant").combat_enabled = false
	hud.visible = false

func _all_enemies_defeated() -> bool:
	for enemy in enemies:
		if enemy.get_node("Combatant").state != Combatant.State.DEAD:
			return false
	return true

func _on_combatant_defeated() -> void:
	_update_hud()

func _update_hud() -> void:
	player_hp.max_value = player_combatant.max_hp
	player_hp.value = player_combatant.hp
	player_initiative.value = player_combatant.initiative
	var active_enemies := 0
	for enemy in enemies:
		var combatant: Combatant = enemy.get_node("Combatant")
		var bars: Dictionary = enemy_bars.get(enemy, {})
		if bars.is_empty():
			continue
		var hp_bar: ProgressBar = bars["hp"]
		var initiative_bar: ProgressBar = bars["initiative"]
		hp_bar.max_value = combatant.max_hp
		hp_bar.value = combatant.hp
		initiative_bar.value = combatant.initiative
		if combatant.state != Combatant.State.DEAD:
			active_enemies += 1
	state_label.text = "PLAYER: %s     ENEMIES ACTIVE: %d" % [player_combatant.state_name(), active_enemies]
