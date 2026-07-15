extends CharacterBody3D

@export var move_speed: float = 6.0
@export var mouse_sensitivity: float = 0.002
@export var jump_velocity: float = 7.5
@export var air_jump_velocity: float = 6.5
@export var gravity_multiplier: float = 1.6
@export var fall_limit: float = -50.0
@export var respawn_height_offset: float = 0.5
@export var interaction_distance: float = 2.0

var last_safe_position: Vector3
var air_jump_available: bool = true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var ignore_next_mouse_motion: bool = true

@onready var camera_rig: Node3D = $CameraRig
@onready var visuals: Node3D = $Visuals
@onready var spring_arm: SpringArm3D = $CameraRig/SpringArm3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	last_safe_position = global_position


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if ignore_next_mouse_motion:
			ignore_next_mouse_motion = false
			return

		camera_rig.rotate_y(-event.relative.x * mouse_sensitivity)

		spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
		spring_arm.rotation.x = clamp(
			spring_arm.rotation.x,
			deg_to_rad(-45.0),
			deg_to_rad(55.0)
		)
		
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("interact"):
		_interact_with_nearest()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta

	if is_on_floor():
		air_jump_available = true
		last_safe_position = global_position

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif air_jump_available:
			velocity.y = air_jump_velocity
			air_jump_available = false

	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var camera_basis := camera_rig.global_transform.basis

	var forward := -camera_basis.z
	var right := camera_basis.x

	forward.y = 0.0
	right.y = 0.0

	forward = forward.normalized()
	right = right.normalized()

	var direction := (
		right * input_direction.x +
		forward * -input_direction.y
	).normalized()

	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		visuals.rotation.y = atan2(-direction.x, -direction.z)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)

	if global_position.y < fall_limit:
		respawn()

	move_and_slide()

func _interact_with_nearest() -> void:
	var nearest_interactable: Node3D = null
	var nearest_distance: float = INF

	for interactable in get_tree().get_nodes_in_group("interactable"):
		if not interactable is Node3D:
			continue

		var distance := global_position.distance_to(
			interactable.global_position
		)

		if distance <= interaction_distance and distance < nearest_distance:
			nearest_interactable = interactable
			nearest_distance = distance

	if nearest_interactable and nearest_interactable.has_method("interact"):
		nearest_interactable.interact()

func respawn() -> void:
	global_position = last_safe_position + Vector3.UP * respawn_height_offset
	velocity = Vector3.ZERO
