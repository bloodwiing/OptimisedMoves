extends CheckButton


export var symbol_theme: Theme
export var use_detailed_symbol := true

var symbol_visible := true


func _ready():
	icon_align = Button.ALIGN_RIGHT

func _process(delta:float):
	if not symbol_visible:
		return
	
	var prefix = "detailed_" if use_detailed_symbol else "flat_"
	
	if (pressed or is_hovered()) and not disabled:
		icon = symbol_theme.get_icon(prefix + "colored", "Symbol")
	else:
		icon = symbol_theme.get_icon(prefix + "gray", "Symbol")

func set_symbol_visible(value:bool):
	symbol_visible = value
	if value:
		icon = null
