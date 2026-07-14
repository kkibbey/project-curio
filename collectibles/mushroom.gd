extends Node3D

@export var collect_lift_height: float = 1.0
@export var collect_duration: float = 0.45

@export var wiggle_interval_min: float = 3.0
@export var wiggle_interval_max: float = 7.0
@export var wiggle_angle: float = 4.0
@export var wiggle_duration: float = 0.12

@onready var visuals: Node3D = $Visuals
@onready var interaction_area: Area3D = $Area3D

var player_in_range: bool = false
var collected: bool = false


func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	_start_wiggle_loop()


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		collect()


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = true


func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = false


func _start_wiggle_loop() -> void:
	while not collected:
		await get_tree().create_timer(
			randf_range(wiggle_interval_min, wiggle_interval_max)
		).timeout

		if not collected:
			_wiggle()


func _wiggle() -> void:
	var start_rotation := visuals.rotation
	var angle := deg_to_rad(wiggle_angle)

	var tween := create_tween()
	tween.tween_property(
		visuals,
		"rotation:z",
		start_rotation.z + angle,
		wiggle_duration
	)
	tween.tween_property(
		visuals,
		"rotation:z",
		start_rotation.z - angle,
		wiggle_duration
	)
	tween.tween_property(
		visuals,
		"rotation:z",
		start_rotation.z,
		wiggle_duration
	)


func collect() -> void:
	if collected:
		return

	collected = true

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		visuals,
		"position:y",
		visuals.position.y + collect_lift_height,
		collect_duration
	)

	tween.tween_property(
		visuals,
		"rotation:y",
		visuals.rotation.y + TAU * 2.0,
		collect_duration
	)

	tween.tween_property(
		visuals,
		"scale",
		Vector3.ZERO,
		collect_duration
	)

	await tween.finished

	print("Collected Red Cap Mushroom")
	queue_free()
