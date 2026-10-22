extends Area2D

@export var speed := 430.0
@export var damage := 16.0
@export var lifetime := 2.2

var direction := Vector2.RIGHT
var source_actor: Node

func _ready() -> void:
	direction = direction.normalized()
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	var target := area.get_parent()
	if target == source_actor or not target.has_node("Combatant"):
		return

	var target_combatant: Combatant = target.get_node("Combatant")
	target_combatant.take_damage(damage)
	queue_free()
