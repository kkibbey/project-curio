extends Node3D

@export var spot_name: String = "Woodland Pond"
@export_range(2, 5) var catches_remaining: int = 3

@export var test_fish_name: String = "Pond Minnow"

@onready var interaction_area: Area3D = $Area3D

var fishing_in_progress: bool = false
var discovered: bool = false

func show_discovery() -> void:
	if discovered:
		return

	discovered = true

	var ui := get_tree().get_first_node_in_group("game_ui")

	if ui:
		ui.show_popup("Fishing spot discovered!")

func _ready() -> void:
	catches_remaining = randi_range(2, 5)
	interaction_area.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node3D) -> void:
	if discovered:
		return

	if body is CharacterBody3D:
		discovered = true

		var ui := get_tree().get_first_node_in_group("game_ui")

		if ui:
			ui.show_popup("Fishing spot discovered!")

func interact() -> void:
	if not discovered:
		show_discovery()
		return

	if fishing_in_progress or catches_remaining <= 0:
		return

	_start_fishing()


func _start_fishing() -> void:
	fishing_in_progress = true
	# open minigame here
	# success -> _complete_catch()
	# failure -> show "It got away!"
	_complete_catch()


func _complete_catch() -> void:
	catches_remaining -= 1
	fishing_in_progress = false

	var ui := get_tree().get_first_node_in_group("game_ui")

	if ui:
		ui.show_popup("You caught a " + test_fish_name + "!")

	print("Caught a ", test_fish_name)

	if catches_remaining <= 0:
		_deplete()


func _deplete() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.35)

	await tween.finished
	queue_free()
