extends Node


var modLoader

var autoload_patches := [
	preload("res://OptimisedMoves/patches/Hitbox.gd"),
	preload("res://OptimisedMoves/patches/ObjectState.gd")
]

var patches = {
}

var lib
var lib_enabled := false

var menu = null


func _init(modLoader):
	self.modLoader = modLoader
	for patch in autoload_patches:
		add_patch(patch)

func add_patch(resource:Resource):
	var data = resource.new()
	var patch = load("res://OptimisedMoves/Patch.gd").new(data, resource, self)
	add_child(patch)
	patch.install(modLoader)
	patches[patch.id] = patch
	print("OptimisedMoves: Patch %s INSTALLED" % patch.id)
	return patch

func get_patch(resource:String):
	return patches[resource]

func set_lib(lib):
	self.lib = lib
	self.lib_enabled = true

func create_options_menu(modOptions):
	menu = modOptions.generate_menu("OptimisedMoves", "Only Optimised Moves")
	
	var logo = menu.add_image("logo", "res://OptimisedMoves/logo.png")
	logo.texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.texture.expand = true
	logo.texture.rect_min_size = Vector2(0, 56)
	
	menu.add_label("version", "Version %s" % get_parent().version)
	
	menu.add_label("patch", "Patches", Label.ALIGN_LEFT)
	
	for patch in get_children():
		var node = menu.add_bool("patch_" + patch.id, patch.name, patch.enabled)
		node.connect("option_changed", patch, "_on_option_changed")
	
	menu.add_label("soon", "More Options coming soon...", Label.ALIGN_LEFT)
	
	modOptions.add_menu(menu)
