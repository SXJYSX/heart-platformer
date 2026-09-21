@tool
extends EditorPlugin

const AUTOLOAD_NAME := "Get"
const AUTOLOAD_PATH := "res://addons/get_node_by_type/get_node_by_type.gd"
const INSPECTOR_PATH := "res://addons/get_node_by_type/custom_inspector.gd"
var inspector_plugin: EditorInspectorPlugin

func _enter_tree():
	inspector_plugin = preload(INSPECTOR_PATH).new()
	add_inspector_plugin(inspector_plugin)
	
	if not ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

func _exit_tree():
	remove_inspector_plugin(inspector_plugin)
	if ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		remove_autoload_singleton(AUTOLOAD_NAME)
