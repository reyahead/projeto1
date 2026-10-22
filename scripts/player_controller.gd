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

func _physics_process(delta: float) -> void:
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)
		velocity.y += get_gravity().y * delta

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
	var acceleration := GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * delta)
	move_and_slide()
