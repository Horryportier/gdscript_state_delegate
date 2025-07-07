extends GdStateDelegateRegistry

static var follow_mouse_ctx: Array[String] = ["agent" , "target_property", "stop_follow_mouse_state", "speed_property"]

static var registry: Dictionary = {
	"follow_mouse": StateDelegate.State.new(_follow_mouse_state\
	, _follow_mouse_enter_state\
	, _follow_mouse_exit_state, "follow_mouse").add_ctx_properties(follow_mouse_ctx)
}

static func _follow_mouse_state(ctx: Dictionary) -> Variant:
	var agent: Node2D = ctx["agent"]
	agent.set(ctx["target_property"], agent.get_global_mouse_position())
	if agent.global_position.distance_to(agent.get_global_mouse_position()) <= 10:
		return ctx["stop_follow_mouse_state"]
	return null

static func _follow_mouse_enter_state(ctx: Dictionary) -> void:
	var agent: Node2D = ctx["agent"]
	var speed: float = agent.get(ctx["speed_property"])
	agent.set(ctx["speed_property"], speed * 2)

static func _follow_mouse_exit_state(ctx: Dictionary) -> void:
	var agent: Node2D = ctx["agent"]
	var speed: float = agent.get(ctx["speed_property"])
	agent.set(ctx["speed_property"], speed * 0.5)

static func get_state(id: String) -> StateDelegate.State:
	return registry.get(id, null)
