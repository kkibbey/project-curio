extends CharacterBody3D

@export var move_speed: float = 6.0
@export var mouse_sensitivity: float = 0.002
@export var jump_velocity: float = 7.5
@export var air_jump_velocity: float = 6.5
@export var gravity_multiplier: float = 1.6

var air_jump_available: bool = true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera_rig: Node3D = $CameraRig

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		camera_rig.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_rig.rotation.x = clamp(
			camera_rig.rotation.x,
			deg_to_rad(-65.0),
			deg_to_rad(45.0)
		)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta

	if is_on_floor():
		air_jump_available = true

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif air_jump_available:
			velocity.y = max(velocity.y, 0.0)
			velocity.y = air_jump_velocity
			air_jump_available = false

	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction := (
		transform.basis * Vector3(input_direction.x, 0.0, input_direction.y)
	).normalized()

	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)

	move_and_slide()
