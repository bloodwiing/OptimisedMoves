extends Node


var resource: Resource
var id := ""
var enabled := false

var patchManager


func _init(patched:Node, path:Resource, patchManager):
	id = patched.__patch_id
	name = patched.__patch_name
	resource = path
	self.patchManager = patchManager

func install(modLoader):
	modLoader.installScriptExtension(resource.resource_path)

func is_enabled():
	return patchManager.lib_enabled and enabled

func set_enabled(state:bool):
	enabled = state
	print("OptimisedMoves: Patch %s %s" % [id, "ENABLED" if enabled else "DISABLED"])

func _on_option_changed(path, state):
	set_enabled(state)
