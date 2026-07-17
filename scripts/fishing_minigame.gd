extends CanvasLayer

signal succeeded
signal failed

@export var marker_speed: float = 300.0

@onready var timing_bar: Control = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TimingBar
@onready var success_zone: ColorRect = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TimingBar/SuccessZone
@onready var moving_marker: ColorRect = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TimingBar/MovingMarker

var marker_direction: float = 1.0
var active: bool = false


func _ready() -> void:
	visible = false
	start()

func _process(delta: float) -> void:
	if not active:
		return

	moving_marker.position.x += marker_speed * marker_direction * delta

	var maximum_x := timing_bar.size.x - moving_marker.size.x

	if moving_marker.position.x >= maximum_x:
		moving_marker.position.x = maximum_x
		marker_direction = -1.0
	elif moving_marker.position.x <= 0.0:
		moving_marker.position.x = 0.0
		marker_direction = 1.0


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return

	if event.is_action_pressed("interact"):
		_check_result()
		get_viewport().set_input_as_handled()


func start() -> void:
	visible = true
	active = true
	marker_direction = 1.0
	moving_marker.position.x = 0.0


func _check_result() -> void:
	active = false
	visible = false

	var marker_center := moving_marker.position.x + moving_marker.size.x * 0.5
	var zone_left := success_zone.position.x
	var zone_right := success_zone.position.x + success_zone.size.x

	if marker_center >= zone_left and marker_center <= zone_right:
		succeeded.emit()
	else:
		failed.emit()
