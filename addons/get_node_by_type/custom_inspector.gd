@tool
extends EditorInspectorPlugin

var _current_object: Object
var get = preload("uid://bb1sq0jheik0t").new()

func _can_handle(object: Object) -> bool:
	return object is Node and object.get_script() != null

func _parse_begin(object: Object) -> void:
	_current_object = object
	
	var button := Button.new()
	button.text = "Auto Assign References"
	button.pressed.connect(_auto_assign_pressed)
	add_custom_control(button)

func _auto_assign_pressed() -> void:
	if not _current_object:
		return
		
	print("--- Auto Assigning Unassigned Node References ---")
	var undo_redo = Engine.get_singleton("EditorInterface").get_editor_undo_redo()
	undo_redo.create_action("Auto Assign Node References")
	
	for prop_info in _current_object.get_property_list():
		if prop_info.type == TYPE_OBJECT and prop_info.hint == PROPERTY_HINT_NODE_TYPE:
			var value = _current_object.get(prop_info.name)
			if value == null:
				var expected_type = prop_info.hint_string
				var found_node := _find_node_by_type(expected_type)
				if found_node:
					print("Assigning ", prop_info.name, "->", found_node.name)
					undo_redo.add_do_property(_current_object, prop_info.name, found_node)
					undo_redo.add_undo_property(_current_object, prop_info.name, null)
				else:
					print("No match found for ", prop_info.name, "(expected:", expected_type, ")")
	undo_redo.commit_action()

func _find_node_by_type(expected_type: String) -> Node:
	var root
	if _current_object.get_parent() is SubViewport:
		root = _current_object
	else:
		root = _current_object.get_parent()
	if not root or expected_type == "":
		return null
	return get.node_by_type(root, expected_type, true)
