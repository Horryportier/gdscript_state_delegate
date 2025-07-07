extends CharacterBody2D

var state: StateDelegate

@export var speed: float = 360


var target: Vector2

var state_ctx: Dictionary

var _follow_state: Callable

func _ready() -> void:
	state = StateDelegate.new()
	state.debug = true
	state.add_state(_idle_state, "idle", _idle_enter_state, _idle_exit_state)
	state.add_state(_wonder_state, "wonder", _wonder_enter_state, _wonder_exit_state)
	_follow_state = state.add_state_from_registry("follow_mouse")
	state_ctx["agent"] = self
	state_ctx["stop_follow_mouse_state"] = _idle_state
	state_ctx["target_property"] = "target"
	state_ctx["speed_property"] = "speed"
	state.set_default_state(_idle_state, state_ctx)
	state.print_registry()


func _physics_process(delta: float) -> void:
	velocity = global_position.direction_to(target) * speed * delta
	move_and_slide()
	state.tick(state_ctx)

func _idle_state(ctx: Dictionary) -> Variant:
	if ctx["begin_wondering"]:
		return _wonder_state
	return null

func _idle_enter_state(ctx: Dictionary) -> void:
	ctx["begin_wondering"]  = false
	get_tree().create_timer(5).timeout.connect(func () -> void:  ctx["begin_wondering"]  = true)
	pass

func _idle_exit_state(ctx: Dictionary) -> void:
	ctx.erase("begin_wondering")

func _wonder_state(_ctx: Dictionary) -> Variant:
	if global_position.distance_to(target) < 10:
		target = Vector2(randf(), randf()) * 1000
	if global_position.distance_to(get_global_mouse_position()) <= 100:
		return _follow_state
	return null

func _wonder_enter_state(_ctx: Dictionary) -> void:
	pass

func _wonder_exit_state(_ctx: Dictionary) -> void:
	pass
