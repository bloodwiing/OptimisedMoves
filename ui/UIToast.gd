extends PanelContainer


var timeout := 10.0
var remaining = timeout


func _process(delta):
	remaining -= delta
	if remaining < 2.0:
		modulate.a = remaining / 2.0
	if remaining <= 0.0:
		queue_free()

func set_text(text:String):
	$ErrorLabel.text = text
