extends CanvasLayer

@onready var found_popup: PanelContainer = $FoundPopup
@onready var found_label: Label = $FoundPopup/MarginContainer/Label

func show_popup(message: String) -> void:
	found_label.text = message
	found_popup.visible = true
	found_popup.modulate.a = 0.0

	var start_y := found_popup.position.y
	found_popup.position.y = start_y - 12.0

	var tween := create_tween()
	tween.tween_property(found_popup, "modulate:a", 1.0, 0.15)
	tween.parallel().tween_property(
		found_popup,
		"position:y",
		start_y,
		0.15
	)

	tween.tween_interval(1.5)
	tween.tween_property(found_popup, "modulate:a", 0.0, 0.3)

	await tween.finished
	found_popup.visible = false
