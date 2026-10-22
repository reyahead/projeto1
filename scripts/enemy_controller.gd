extends CharacterBody2D

const MOVE_SPEED := 105.0
const STOP_DISTANCE := 73.0
const PATROL_SPEED := 24.0
const PATROL_DISTANCE := 46.0

@export var target_path: NodePath

var facing := -1
var patrol_direction := 1.0
var home_x := 0.0
@onready var target: CharacterBody2D = get_node(target_path)
@onready var combatant: Combatant = $Combatant

func _ready() -> void:
	add_to_group("enemies")
	home_x = global_position.x
	combatant.defeated.connect(_on_defeated)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	if not combatant.combat_enabled:
		if combatant.state != Combatant.State.DEAD:
			if absf(global_position.x - home_x) > PATROL_DISTANCE:
				patrol_direction *= -1.0
			velocity.x = patrol_direction * PATROL_SPEED
		else:
			velocity.x = 0.0
		move_and_slide()
		return

	if target == null or combatant.state == Combatant.State.DEAD:
		velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED * delta)
		move_and_slide()
		return

	var offset := target.global_position - global_position
	var horizontal_distance := absf(offset.x)
	facing = 1 if offset.x > 0.0 else -1

	if horizontal_distance > STOP_DISTANCE:
		velocity.x = float(facing) * MOVE_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED * 2.0 * delta)
		if combatant.state == Combatant.State.READY and combatant.initiative >= 100.0:
			combatant.begin_attack()

	move_and_slide()

func _on_defeated() -> void:
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
