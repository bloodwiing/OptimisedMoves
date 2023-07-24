extends "res://mechanics/Hitbox.gd"


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


func copy_to(hitbox:CollisionBox):
	if not Custom.OptimisedMoves.run_patch_safe("_PropertySnapshots", self, "_PropertySnapshots_copy_to", [hitbox]):
		return .copy_to(hitbox)

func _PropertySnapshots_copy_to(hitbox:CollisionBox):
	_PropertySnapshots.lib.copy_properties(self, hitbox)
