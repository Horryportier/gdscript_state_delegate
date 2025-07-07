@tool
class_name GdStateDelegateSettings

const ROOT_PATH: String = "gd_state_delegate/"

const GENERIC_STATE_PATH_FILE: String = "paths/global_state"


const SETTINGS_CONFIGURATION: Dictionary = {
		GENERIC_STATE_PATH_FILE: {
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"value": ""
		},
}


static func setup() -> void:
	print_rich("[i][color=green]GDStateDelagetSettings: setting up project settings[/color][i]")
	for key in SETTINGS_CONFIGURATION.keys():
		var setting_config: Dictionary = SETTINGS_CONFIGURATION[key]
		var setting_name: String = ROOT_PATH + key
		if not ProjectSettings.has_setting(setting_name):
			ProjectSettings.set_setting(setting_name, setting_config.value)
		ProjectSettings.set_initial_value(setting_name, setting_config.value)
		ProjectSettings.add_property_info({
			"name" = setting_name,
			"type" = setting_config.type,
			"hint" = setting_config.get("hint", PROPERTY_HINT_NONE),
			"hint_string" = setting_config.get("hint_string", "")
		})
		ProjectSettings.set_as_basic(setting_name, not setting_config.has("is_advanced"))
		ProjectSettings.set_as_internal(setting_name, setting_config.has("is_hidden"))

static func get_setting(path: String) -> Variant:
		return ProjectSettings.get(ROOT_PATH + path)
	
