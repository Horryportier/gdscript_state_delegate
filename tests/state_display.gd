extends RichTextLabel

@export var state_property: String = "state"
@export var format_string: String = "[color=green]%s[/color]"
@onready var agent: Node = get_parent()


var state: StateDelegate

func _process(_delta: float) -> void:
	if agent.state == null:
		return
	state  = agent.state
	state.state_changed.connect(_on_state_changed)
	set_process(false)

func _on_state_changed(_old_state: Callable, new_state: Callable) -> void:
	text = format_string % [state.get_state_name(new_state)] 
