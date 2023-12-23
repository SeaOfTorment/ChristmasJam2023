extends Panel


@onready var option_button = $"HBoxContainer/visual_panel/HBoxContainer/MarginContainer/OptionButton"
func _ready():
	option_button.add_item("Windowed")
	option_button.add_item("Fullscreen")


func _on_option_button_item_selected(index):
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		get_window().size = Vector2i(1152, 648)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

