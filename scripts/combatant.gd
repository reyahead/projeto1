extends Node
class_name Combatant

signal changed
signal attack_window
signal projectile_window
signal defense_started
signal defense_ended
signal attack_ended
signal defeated

enum State { READY, WINDUP, EXECUTING, RECOVERY, DEAD }
enum Ability { MELEE, PROJECTILE, DEFENSE }

@export var max_hp := 100.0
@export var initiative_speed := 50.0
@export var damage := 20.0
@export var windup_seconds := 0.15
@export var execution_seconds := 0.20
@export var recovery_seconds := 0.45
@export var projectile_damage := 16.0
@export var projectile_windup_seconds := 0.60
@export var projectile_recovery_seconds := 0.50
@export var defense_windup_seconds := 0.10
@export var defense_duration_seconds := 1.0
@export var defense_recovery_seconds := 0.35
@export_range(0.0, 1.0) var defense_damage_multiplier := 0.40

var combat_enabled := false
var hp := 100.0
var initiative := 0.0
var state := State.READY
var current_ability := Ability.MELEE
var is_defending := false
var _phase_time := 0.0

func _ready() -> void:
	hp = max_hp
	changed.emit()

func _process(delta: float) -> void:
	if not combat_enabled or state == State.DEAD:
		return

	# A barra continua avançando durante preparação, execução e recuperação.
	initiative = minf(100.0, initiative + initiative_speed * delta)

	if state != State.READY:
		_phase_time -= delta
		if _phase_time <= 0.0:
			_advance_action()

	changed.emit()

func begin_attack() -> bool:
	return _begin_ability(Ability.MELEE)

func begin_projectile() -> bool:
	return _begin_ability(Ability.PROJECTILE)

func begin_defense() -> bool:
	return _begin_ability(Ability.DEFENSE)

func _begin_ability(ability: Ability) -> bool:
	if state != State.READY or initiative < 100.0:
		return false

	initiative = 0.0
	current_ability = ability
	state = State.WINDUP
	match ability:
		Ability.MELEE:
			_phase_time = windup_seconds
		Ability.PROJECTILE:
			_phase_time = projectile_windup_seconds
		Ability.DEFENSE:
			_phase_time = defense_windup_seconds
	changed.emit()
	return true

func take_damage(amount: float) -> void:
	if state == State.DEAD:
		return

	var final_amount := amount * (defense_damage_multiplier if is_defending else 1.0)
	hp = maxf(0.0, hp - final_amount)
	if hp <= 0.0:
		attack_ended.emit()
		defense_ended.emit()
		is_defending = false
		state = State.DEAD
		initiative = 0.0
		defeated.emit()
	changed.emit()

func state_name() -> String:
	return State.keys()[state]

func _advance_action() -> void:
	match state:
		State.WINDUP:
			state = State.EXECUTING
			match current_ability:
				Ability.MELEE:
					_phase_time = execution_seconds
					attack_window.emit()
				Ability.PROJECTILE:
					_phase_time = 0.01
					projectile_window.emit()
				Ability.DEFENSE:
					_phase_time = defense_duration_seconds
					is_defending = true
					defense_started.emit()
		State.EXECUTING:
			state = State.RECOVERY
			if current_ability == Ability.PROJECTILE:
				_phase_time = projectile_recovery_seconds
			elif current_ability == Ability.DEFENSE:
				_phase_time = defense_recovery_seconds
			else:
				_phase_time = recovery_seconds
			if current_ability == Ability.DEFENSE:
				is_defending = false
				defense_ended.emit()
			attack_ended.emit()
		State.RECOVERY:
			state = State.READY
			_phase_time = 0.0
	changed.emit()
