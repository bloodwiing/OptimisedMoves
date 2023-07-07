extends "res://ObjectState.gd"


var __patch_id = "objectstate"
var __patch_name = "Object State Copying"

var OptimisedMoves


# Original
func __copy_to(state:ObjectState):
	var properties = get_script().get_script_property_list()
	for variable in properties:
		var value = get(variable.name)
		if not (value is Object or value is Array or value is Dictionary):
			state.set(variable.name, value)
	state.data = copy_data()
	state.current_real_tick = current_real_tick
	state.current_tick = current_real_tick
	for h in get_children():
		if (h is Hitbox):
			h.copy_to(state.get_node(h.name))

# Optimised
func copy_to(state:ObjectState):
	if OptimisedMoves == null:
		OptimisedMoves = ModLoader.get_node("OptimisedMoves")
	
	if not OptimisedMoves.get_patch(__patch_id).is_enabled():
		__copy_to(state)
		return
		
	OptimisedMoves.lib.copy_properties(self, state)
	state.data = OptimisedMoves.lib.duplicate_data(data)

	state.current_real_tick = current_real_tick
	state.current_tick = current_real_tick
	
	for h in get_children():
		if (h is Hitbox):
			h.copy_to(state.get_node(h.name))
