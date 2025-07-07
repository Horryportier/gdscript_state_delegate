@tool
extends EditorPlugin


func _enter_tree() -> void:
	var settings: GdStateDelegateSettings = load("res://addons/gdstatedelegate/src/settings.gd").new()
	settings.setup()
	
func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
