extends Area2D

const PROJECTILE_SCENE := preload("res://scenes/combat/projectile.tscn")

@onready var combatant: Combatant = get_parent().get_node("Combatant")
@onready var hit_shape: CollisionShape2D = $CollisionShape2D
@onready var defense_visual: CanvasItem = get_parent().get_node_or_null("DefenseAura")

var hit_targets: Array[Node] = []

func _ready() -> void:
	monitoring = false
	monitorable = false
	hit_shape.disabled = true
	combatant.attack_window.connect(_open_hit_window)
	combatant.projectile_window.connect(_launch_projectile)
	combatant.defense_started.connect(_show_defense)
	combatant.defense_ended.connect(_hide_defense)
	combatant.attack_ended.connect(_close_hit_window)
	area_entered.connect(_on_area_entered)

func _open_hit_window() -> void:
	hit_targets.clear()
	var actor := get_parent()
	var facing := int(actor.get("facing"))
	position.x = float(facing) * 39.0
	monitoring = true
	hit_shape.set_deferred("disabled", false)

func _close_hit_window() -> void:
	monitoring = false
	hit_shape.set_deferred("disabled", true)

func _on_area_entered(area: Area2D) -> void:
	var target := area.get_parent()
	if target == get_parent() or hit_targets.has(target):
		return
	if not target.has_node("Combatant"):
		return

	hit_targets.append(target)
	var target_combatant: Combatant = target.get_node("Combatant")
	target_combatant.take_damage(combatant.damage)

func _launch_projectile() -> void:
	var actor := get_parent()
	var facing := int(actor.get("facing"))
	var projectile: Area2D = PROJECTILE_SCENE.instantiate()
	projectile.global_position = actor.global_position + Vector2(float(facing) * 28.0, -5.0)
	var direction := Vector2(float(facing), 0.0)
	var target_group := "player" if actor.is_in_group("enemies") else "enemies"
	var nearest_distance := INF
	for candidate in get_tree().get_nodes_in_group(target_group):
		if not candidate.has_node("Combatant"):
			continue
		var candidate_combatant: Combatant = candidate.get_node("Combatant")
		if candidate_combatant.state == Combatant.State.DEAD:
			continue
		var distance: float = actor.global_position.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			direction = (candidate.global_position - projectile.global_position).normalized()
	projectile.set("direction", direction)
	projectile.set("damage", combatant.projectile_damage)
	projectile.set("source_actor", actor)
	get_tree().current_scene.add_child(projectile)

func _show_defense() -> void:
	if defense_visual:
		defense_visual.visible = true

func _hide_defense() -> void:
	if defense_visual:
		defense_visual.visible = false
