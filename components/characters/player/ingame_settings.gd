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


func _on_check_button_toggled(toggled_on): #fancy lights
	$"../../../WorldEnvironment".environment.sdfgi_enabled = toggled_on
 
func _on_check_button_2_toggled(toggled_on): #snow
	for i in $"../../../snow".get_children():
		i.emitting = toggled_on


func _on_check_button_toggled_fsr(toggled_on):
	if toggled_on:
		#ProjectSettings.set_setting("rendering/scaling_3d/mode", 2)
		#ProjectSettings.set_setting("rendering/scaling_3d/scale", 0.4)
		#ProjectSettings.save()
		get_viewport().set_scaling_3d_mode(Viewport.SCALING_3D_MODE_FSR2)
		get_viewport().set_scaling_3d_scale($"HBoxContainer/visual_panel/far_scaling/MarginContainer3/HSlider".value/100)
		$"HBoxContainer/visual_panel/far_scaling".visible = true
	else:
		get_viewport().set_scaling_3d_mode(Viewport.SCALING_3D_MODE_BILINEAR)
		get_viewport().set_scaling_3d_scale(1.00)
		$"HBoxContainer/visual_panel/far_scaling".visible = false
		#ProjectSettings.set_setting("rendering/scaling_3d/mode", 0)
		#ProjectSettings.set_setting("rendering/scaling_3d/scale", 1)
		#ProjectSettings.save()


func _on_h_slider_value_changed(value):
	get_viewport().set_scaling_3d_scale($"HBoxContainer/visual_panel/far_scaling/MarginContainer3/HSlider".value/100)


func _on_back_pressed():
	var players = get_tree().get_nodes_in_group("player")
	for i in players:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		i.mouse_lock = true
		visible = false

func _on_quit_pressed():
	get_tree().quit()


func _on_check_button_toggled_1(toggled_on):
	$"../../../WorldEnvironment".environment.ssao_enabled = toggled_on
	
	


func _on_check_button_2_toggled_vol(toggled_on):
	$"../../../WorldEnvironment".environment.volumetric_fog_enabled = toggled_on


func _on_check_button_toggled_ssil(toggled_on):
	$"../../../WorldEnvironment".environment.ssil_enabled = toggled_on


func _on_h_slider_value_changed_audio(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value/100))


func _on_check_button_toggled_muted(toggled_on):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), toggled_on)


func _on_visual_pressed():
	$HBoxContainer/audio_panel.visible = false
	$HBoxContainer/visual_panel.visible = true


func _on_audio_pressed():
	$HBoxContainer/visual_panel.visible = false
	$HBoxContainer/audio_panel.visible = true
