class_name StateDelegate
extends RefCounted

###################################################################################################
## StateDelagete: is simple finate state machine class that uses function pointers to menage state #
###################################################################################################

signal state_changed(old_state: Callable, new_state: Callable)

static var global_registry: GdStateDelegateRegistry 

class State:
	## state tick is main loop of state that returns null when no state change and other state function when state changes
	var tick: Callable
	## state enter is called when state is being chanded its an setup function that returns nothing 
	var enter: Callable
	## state exit is called when current state is invalid 
	var exit: Callable
	var name: String = "NONE"

	func _init(_state: Callable, _enter: Callable, _exit: Callable, _name: String = "") -> void:
		tick = _state
		enter = _enter
		exit = _exit
		name = _name
	
var _registry: Dictionary = {}


## if set to true it will print state transition 
var debug: bool = false:
	set(val):
		debug = val
		if debug:
			state_changed.connect(_on_state_changed)
		else:
			state_changed.disconnect(_on_state_changed)

var _state_tansition_complete: bool = false

var _current_state: Callable

var _enter_state_fn_default: = func() -> void: return
var _exit_state_fn_default: = func() -> void: return 


## add state ads state to registry you need to provide at least tick state function 
## name defaults to empty string "", enter and exit default to empty fuctions
func add_state(state: Callable, name: String = "",  enter: Callable = _enter_state_fn_default, exit: Callable = _exit_state_fn_default) -> void:
	_registry[state] = State.new(state, enter, exit)
	_registry.get(state).name = name

func add_state_from_registry(id: String) -> Callable: 
	if global_registry == null:
		var global_registry_file: String = GdStateDelegateSettings.get_setting(GdStateDelegateSettings.GENERIC_STATE_PATH_FILE)
		if global_registry_file != "":
			global_registry = load(global_registry_file).new()
		else:
			push_warning("global registry not specified go to settings -> gd_state_delegate/paths/global_states")
			return func (_ctx: Dictionary) -> Variant: return null
	var state: State = global_registry.get_state(id)
	if state == null:
		push_warning("failed to load state from global_registry: ", id)
		return func (_ctx: Dictionary) -> Variant: return null
	_registry[state.tick] = state
	return state.tick
	

## set startarting state
func set_default_state(state: Callable, ctx: Dictionary = {}) -> void:
	if _registry.has(state): 
		_handle_state_transition(state, ctx)
	else:
		push_warning("registry dose not have [%s] state" % [state])

## sets current state can be used oudside of the state functions
func set_state(state: Callable) -> void:
	if !_registry.has(state):
		push_warning("registry dose not have [%s] state" % [state])
		return
	_current_state = state

## gets states name 
func get_state_name(state: Callable) -> String:
	if !_registry.has(state):
		push_warning("registry dose not have [%s] state" % [state])
		return "INVALID STATE"
	return _registry.get(state).name

	
## when called it will execute current state
## you can run it in proccess or on timer depending on your needs 
func tick(ctx: Dictionary = {}) -> void:
	if !_state_tansition_complete:
		return
	var state: State = _registry.get(_current_state)
	var res: Variant = await state.tick.call(ctx)
	match typeof(res):
		TYPE_NIL:
			return
		TYPE_CALLABLE:
			if !_registry.has(res):
				push_warning("current state returned invalid state function")
				return 
			_handle_state_transition(_registry.get(res).tick, ctx)

func _handle_state_transition(new_state: Callable, ctx: Dictionary) -> void:
	if _current_state != new_state:
			_state_tansition_complete = false
			var state: State = _registry.get(_current_state)
			if state:
				await state.exit.call(ctx)
			state = _registry.get(new_state)
			await state.enter.call(ctx)
			state_changed.emit(_current_state, new_state) 
			_current_state = new_state
			_state_tansition_complete = true

## prints state registry data
func print_registry() -> void: 
	for v: Callable in _registry.keys():
		var state: State = _registry.get(v)
		print_rich("Name: %s, tick: %s, enter: %s, exit: %s" % [state.name, state.tick, state.enter, state.exit])

## Cheacks if current_state is equal to passed state
func is_state(state: Callable) -> bool:
	if state == _current_state:
		return true
	return false

func _on_state_changed(old_state: Callable, new_state: Callable) -> void:
	var old_state_name: String = "NONE"
	if _registry.has(old_state):
		old_state_name = _registry.get(old_state).name
	print_rich("state changed from [color=orange]%s[/color] to [color=green]%s[/color]" % 
	[old_state_name, _registry.get(new_state).name])
