@tool
class_name SaverNode extends Node

const SAVER_NODE_GROUP: String = "saver_node"
@export var properties_to_save: Array[String] = []

func _ready() -> void:
	add_to_group(SAVER_NODE_GROUP)

func get_save_dict() -> Dictionary:
	var parent = get_parent()
	var node_data = {}
	for prop in properties_to_save:
		if prop in parent:
			node_data[prop] = parent.get(prop)
	return node_data

func apply_save_dict(node_data: Dictionary) -> void:
	var parent = get_parent()
	for prop in node_data:
		if prop in parent:
			parent.set(prop, node_data[prop])
