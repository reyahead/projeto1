extends CharacterBody2D

const FLY_SPEED := 115.0
const PREFERRED_DISTANCE := 155.0
const HEIGHT_OFFSET := 78.0

@export var target_path: NodePath

var facing := -1
var home_position := Vector2.ZERO
var hover_time := 0.0
@onready var target: CharacterBody2D = get_node(target_path)
@onready var combatant: Combatant = $Combatant

func _ready() -> void:
	add_to_group("enemies")
	home_position = global_position
	combatant.defeated.connect(_on_defeated)

func _physics_process(delta: float) -> void:
	hover_time += delta
	if combatant.state == Combatant.State.DEAD or target == null:
		velocity = Vector2.ZERO
		return

	if not combatant.combat_enabled:
		global_position.y = home_position.y + sin(hover_time * 1.6) * 9.0
		return

	var to_player := target.global_position - global_position
	facing = 1 if to_player.x > 0.0 else -1
	var desired_position := target.global_position + Vector2(float(-facing) * PREFERRED_DISTANCE, -HEIGHT_OFFSET)
	var offset := desired_position - global_position
	velocity = offset.limit_length(FLY_SPEED)
	move_and_slide()

	if combatant.state == Combatant.State.READY and combatant.initiative >= 100.0:
		combatant.begin_projectile()

func _on_defeated() -> void:
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
