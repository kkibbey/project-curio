extends Node3D

@export var spot_name: String = "Woodland Pond"
@export_range(2, 5) var catches_remaining: int = 3

@export var test_fish_name: String = "Pond Minnow"

var fishing_in_progress: bool = false


func _ready() -> void:
	catches_remaining = randi_range(2, 5)


func interact() -> void:
	if fishing_in_progress or catches_remaining <= 0:
		return

	_start_fishing()


func _start_fishing() -> void:
	fishing_in_progress = true

	# Temporary stand-in for the future timing minigame.
	await get_tree().create_timer(1.0).timeout

	_complete_catch()


func _complete_catch() -> void:
	catches_remaining -= 1
	fishing_in_progress = false

	var ui := get_tree().get_first_node_in_group("game_ui")

	if ui:
		ui.show_found_item("You caught a " + test_fish_name + "!")

	print("Caught a ", test_fish_name)

	if catches_remaining <= 0:
		_deplete()


func _deplete() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.35)

	await tween.finished
	queue_free()
