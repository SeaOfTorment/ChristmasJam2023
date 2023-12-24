extends Control


var index = 0
var lines = []

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	pass # Replace with function body.


func display_text(user, text_lines):
	show()
	$Name.text = user
	
	index = 0
	lines = text_lines
	
	show_line()
	
func show_line():
	if index < lines.size():
		$Content.text = lines[index]
	else:
		hide()

func resize_font():
	var font = $Content.get_font()
	font.size = 20
	$Content.add_font_override("string_name", font)


func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		index += 1
		show_line()