extends "res://ObjectState.gd"


var _PropertySnapshots = null

var _OptiMoves_Property_Snapshot = null


func init():
	if not Custom.OptimisedMoves.run_patch_safe("_PropertySnapshots", self, "_PropertySnapshots_init", []):
		return .init()

func raw_init():
	.init()

func _PropertySnapshots_init():
	raw_init()
	_PropertySnapshots.lib.snapshot_properties(self)


func copy_to(state:ObjectState):
	if not Custom.OptimisedMoves.run_patch_safe("_PropertySnapshots", self, "_PropertySnapshots_copy_to", [state]):
		return .copy_to(state)

func _PropertySnapshots_copy_to(state:ObjectState):
	_PropertySnapshots.lib.copy_properties(self, state)
	state.data = _PropertySnapshots.lib.duplicate_data(data)
	
	state.current_real_tick = current_real_tick
	state.current_tick = current_real_tick
	
	for h in get_children():
		if (h is Hitbox):
			h.copy_to(state.get_node(h.name))
