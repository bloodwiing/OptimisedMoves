extends "res://OptimisedMoves/patch/Patch.gd"


static func get_patch_info(info:=PatchInfo.new()) -> PatchInfo:
	info.id = "LazyPropertySnapshots"
	info.name = "Lazy Property Snapshots"
	info.description = "Disables Property Snapshotting FROM \"Ghosts\" (aka Predictions)"
	info.support = info.VersionSupport.new("1.7.0", "1.7.0")
	info.revision = 1
	info.add_requirement("res://OptimisedMoves/patch/PropertySnapshots/_Load.gd")
	return info

func install(modLoader: ModLoader):
	modLoader.installScriptExtension("res://OptimisedMoves/patch/LazyPropertySnapshots/Hitbox.gd")
	modLoader.installScriptExtension("res://OptimisedMoves/patch/LazyPropertySnapshots/ObjectState.gd")

func _init(patchManager).(patchManager):
	set_support_state(SupportState.ALLOW_WARN_UNTESTED, "")
	pass
