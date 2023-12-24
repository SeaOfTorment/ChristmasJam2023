extends Control

signal done

var index = 0
var lines = []

var counter = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	pass # Replace with function body.


func display_text(user, text_lines):
	show()
	$Name.text = user
	counter = 0.5
	index = 0
	lines = text_lines
	
	show_line()
	
func show_line():
	if index < lines.size():
		$Content.text = lines[index]
	else:
		done.emit()
		hide()

func resize_font():
	var font = $Content.get_font()
	font.size = 20
	$Content.add_font_override("string_name", font)


func _process(delta):
	counter -= delta
	if Input.is_action_just_pressed("ui_accept") or (counter < 0 and Input.is_action_just_pressed("interact")):
		index += 1
		show_line()
