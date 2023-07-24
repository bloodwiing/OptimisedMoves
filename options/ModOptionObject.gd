extends "res://SoupModOptions/OptionTypes/ModOptionObject.gd"


enum FlagOptionParentBehaviour {
	IGNORE = 0,
	
	REQUIRE_ELSE_DISABLED = 1,
	REQUIRE_ELSE_FALSE = 2,
	
	REQUIRE_ELSE_DISABLED_AND_FALSE = 3,
}


var use_custom_tooltip := false
var custom_tooltip = null

var force_disabled := false

var parent_option
var parent_behaviour_flags = FlagOptionParentBehaviour.REQUIRE_ELSE_DISABLED


func _build():
	pass

func is_inheritely_disabled():
	return false

func set_disabled(value:bool):
	emit_signal("option_changed", fullpath, current_value)

func set_force_disabled(value:bool):
	force_disabled = value
	set_disabled(force_disabled)
	if parent_option:
		on_parent_update(parent_option.fullpath, parent_option.current_value)

func set_parent_option(node:Node):
	parent_option = node
	parent_option.connect("option_changed", self, "on_parent_update")
	on_parent_update(parent_option.fullpath, parent_option.current_value)

func on_parent_update(path, value):
	var is_require_fulfilled = true if parent_option.is_inheritely_disabled() else not value
	
	if parent_behaviour_flags & FlagOptionParentBehaviour.REQUIRE_ELSE_FALSE:
		if has_method("set_value") and is_require_fulfilled:
			call("set_value", false)
	
	if force_disabled:
		set_disabled(true)
	elif parent_behaviour_flags & FlagOptionParentBehaviour.REQUIRE_ELSE_DISABLED:
		set_disabled(is_require_fulfilled)

func _make_custom_tooltip(for_text):
	if not use_custom_tooltip:
		return ._make_custom_tooltip(for_text)
	return custom_tooltip.new(for_text)
