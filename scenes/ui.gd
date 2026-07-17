extends CanvasLayer

@onready var found_popup: PanelContainer = $FoundPopup
@onready var found_label: Label = $FoundPopup/MarginContainer/Label
@onready var interaction_prompt: PanelContainer = $InteractionPrompt
@onready var prompt_label: Label = $InteractionPrompt/MarginContainer/PromptLabel

var popup_tween: Tween = null
var popup_version: int = 0

func show_popup(message: String) -> void:
	popup_version += 1
	var this_popup_version := popup_version

	if popup_tween and popup_tween.is_valid():
		popup_tween.kill()

	found_label.text = message
	found_popup.visible = true
	found_popup.modulate.a = 0.0

	var resting_y := found_popup.position.y
	found_popup.position.y = resting_y - 12.0

	popup_tween = create_tween()

	popup_tween.tween_property(
		found_popup,
		"modulate:a",
		1.0,
		0.15
	)

	popup_tween.parallel().tween_property(
		found_popup,
		"position:y",
		resting_y,
		0.15
	)

	popup_tween.tween_interval(1.5)

	popup_tween.tween_property(
		found_popup,
		"modulate:a",
		0.0,
		0.3
	)

	await popup_tween.finished

	if this_popup_version != popup_version:
		return

	found_popup.visible = false
	popup_tween = null

func show_interaction_prompt(action_text: String) -> void:
	prompt_label.text = "[E]\n" + action_text
	interaction_prompt.visible = true


func hide_interaction_prompt() -> void:
	interaction_prompt.visible = false
