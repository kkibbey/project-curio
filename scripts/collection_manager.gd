extends Node

var discovered_items: Dictionary = {}


func has_discovered(item_id: String) -> bool:
	return discovered_items.has(item_id)


func discover(item_id: String) -> bool:
	if has_discovered(item_id):
		return false

	discovered_items[item_id] = true
	return true
