extends "res://SoupModOptions/OptionTypes/ModOptionObject.gd"


const SymbolButton := preload("res://OptimisedMoves/options/generic/symbol/SymbolButton.gd")
var btn:SymbolButton


func _build():
	btn = SymbolButton.new()
	btn.text = display_name
	btn.pressed = current_value
	btn.mouse_filter = MOUSE_FILTER_PASS
	add_child(btn)
	btn.connect("toggled",self,"option_changed")
	
func option_changed(value):
	set_value(value)
	emit_signal("option_changed", fullpath, value)
	
func set_value(value:bool):
	btn.pressed = value
	current_value = value

func set_symbol(theme:Theme):
	btn.symbol_theme = theme

func set_symbol_visible(value:bool):
	btn.set_symbol_visible(value)

func is_inheritely_disabled():
	return btn.is_disabled() and not force_disabled

func set_disabled(value:bool):
	btn.disabled = value
	.set_disabled(value)
