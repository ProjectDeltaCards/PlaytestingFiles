extends Control

@onready var window = $"../Window"

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		window.popup()
		
