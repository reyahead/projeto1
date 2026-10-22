extends CharacterBody2D

const SPEED := 260.0
const GROUND_ACCELERATION := 1800.0
const AIR_ACCELERATION := 1050.0
const JUMP_VELOCITY := -520.0
const JUMP_CUT_MULTIPLIER := 0.48
const COYOTE_TIME := 0.12
const JUMP_BUFFER_TIME := 0.12

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var facing := 1
var _drop_platform: StaticBody2D
var _drop_platform_bottom := 0.0

@onready var combatant: Combatant = $Combatant

func _ready() -> void:
	add_to_group("player")

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	match event.physical_keycode:
		KEY_F:
			combatant.begin_attack()
		KEY_G:
			combatant.begin_projectile()
		KEY_Q:
			combatant.begin_defense()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		_try_drop_through_platform()

	if not is_on_floor():
		coyote_timer = maxf(coyote_timer - delta, 0.0)
		velocity.y += get_gravity().y * delta
	else:
		coyote_timer = COYOTE_TIME

	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
	elif Input.is_action_just_released("ui_accept") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	var direction := Input.get_axis("ui_left", "ui_right")
	if not is_zero_approx(direction):
		facing = 1 if direction > 0.0 else -1
	var acceleration := GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * delta)
	move_and_slide()
	_update_drop_through_platform()

func _try_drop_through_platform() -> void:
	if not is_on_floor() or _drop_platform != null:
		return

	var ray_start := global_position + Vector2(0.0, 16.0)
	var ray_end := global_position + Vector2(0.0, 40.0)
	var query := PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.exclude = [get_rid()]
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	var platform := hit.get("collider") as StaticBody2D
	if platform == null or not platform.is_in_group("platforms"):
		return

	var platform_shape := platform.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if platform_shape == null or not (platform_shape.shape is RectangleShape2D):
		return

	var rectangle := platform_shape.shape as RectangleShape2D
	_drop_platform = platform
	_drop_platform_bottom = platform.global_position.y + rectangle.size.y * 0.5
	add_collision_exception_with(platform)
	velocity.y = maxf(velocity.y, 80.0)

func _update_drop_through_platform() -> void:
	if _drop_platform == null:
		return
	if global_position.y > _drop_platform_bottom + 23.0:
		remove_collision_exception_with(_drop_platform)
		_drop_platform = null
