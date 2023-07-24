extends "res://mechanics/Hitbox.gd"


var _LazyPropertySnapshots = null


func _PropertySnapshots_init():
	if not Custom.OptimisedMoves.run_patch_safe("_LazyPropertySnapshots", self, "_LazyPropertySnapshots_init", []):
		return ._PropertySnapshots_init()

func _LazyPropertySnapshots_init():
	if get_parent().get_parent().get_parent().is_ghost:
		.raw_init()
	else:
		._PropertySnapshots_init()
