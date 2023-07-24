extends "res://OptimisedMoves/patch/Patch.gd"


static func get_patch_info(info:=PatchInfo.new()) -> PatchInfo:
	info.id = "PropertySnapshots"
	info.name = "Property Snapshots"
	info.description = "Speeds up Predictions and reduces stutter"
	info.support = info.VersionSupport.new("1.7.0", "1.7.0")
	info.revision = 3
	return info

func install(modLoader: ModLoader):
	modLoader.installScriptExtension("res://OptimisedMoves/patch/PropertySnapshots/Hitbox.gd")
	modLoader.installScriptExtension("res://OptimisedMoves/patch/PropertySnapshots/ObjectState.gd")

func _init(patchManager).(patchManager):
	pass
