extends Label


var fps_cooldown := 0.0
var fps_lowest := 0
var active := true


func _ready():
	align = ALIGN_RIGHT
	margin_left = -80
	margin_right = 0
	anchor_left = 1.0
	anchor_right = 1.0
	rect_position.x = 560
	rect_size.x = 80
	rect_pivot_offset.x = 80
	theme = preload("res://theme.tres")

func _process(delta):
	if not active:
		return
	
	var fps = round(1.0 / delta)
	
	fps_cooldown -= delta
	
	if fps <= fps_lowest and fps < 50:
		fps_lowest = fps
		fps_cooldown = 2.0
		
	if fps_cooldown <= 0:
		fps_lowest = fps
		
	text = "%d (%d) FPS" % [fps, fps_lowest]
	add_color_override("font_color", Color(1.0, 0.2, 0.2) if fps_lowest < 50 else Color.white)

func _on_state_change(path, state):
	active = state
	if not state:
		hide()
	else:
		show()
