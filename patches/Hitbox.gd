extends "res://mechanics/Hitbox.gd"


var __patch_id = "hitbox"
var __patch_name = "Hitbox Copying"

var OptimisedMoves = null


# Original
func __copy_to(hitbox:CollisionBox):
	var properties = get_script().get_script_property_list()
	for variable in properties:
		var value = get(variable.name)
		if not (value is Object or value is Array or value is Dictionary):
			hitbox.set(variable.name, value)

# Optimised
func copy_to(hitbox:CollisionBox):
	if OptimisedMoves == null:
		OptimisedMoves = ModLoader.get_node("OptimisedMoves")
	
	if not OptimisedMoves.get_patch(__patch_id).is_enabled():
		__copy_to(hitbox)
		return
	
	OptimisedMoves.lib.copy_properties(self, hitbox)
