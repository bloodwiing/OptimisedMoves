extends Node


const Patch = preload("res://OptimisedMoves/patch/Patch.gd")
const PatchInfo = preload("res://OptimisedMoves/patch/PatchInfo.gd")

const label_color := Color(0.5, 0.5, 0.5)


var modLoader

var autoload_patches := [
	"res://OptimisedMoves/patch/LazyPropertySnapshots/_Load.gd",
	"res://OptimisedMoves/patch/PropertySnapshots/_Load.gd",
	"res://OptimisedMoves/patch/DisableVSync/_Load.gd",
]

var patches = {
}
var require_dict = {
}

var allow_any := true
var allow_denied := false

var lib
var lib_enabled := false

var modOptions
var menu = null
var use_detailed_icons := true

var game_version: PatchInfo.Version


func _init(modLoader):
	name = "PatchManager"
	game_version = preload("res://OptimisedMoves/patch/PatchInfo.gd").Version.new(Global.VERSION)
	print("OptimisedMoves: Game version = %s" % game_version)
	self.modLoader = modLoader
	for patch in autoload_patches:
		add_patch(load(patch))

func add_patch(resource:Resource):
	var info: PatchInfo = resource.get_patch_info()
	
	for requirement in info.requires:
		var req_id = requirement.get_patch_info().id
		if not req_id in patches:
			if not req_id in require_dict:
				require_dict[req_id] = []
			require_dict[req_id].append(resource)
			return
	
	var patch = resource.new(self)
	add_child(patch)
	patch.install(modLoader)
	patches[info.id] = patch
	print("OptimisedMoves: Patch %s INSTALLED" % info.id)
	
	if info.id in require_dict:
		for secondary in require_dict[info.id]:
			var sec_patch = add_patch(secondary)
			patch.add_depends_by(sec_patch)
		require_dict.erase(info.id)
	
	return patch

func get_patch(id:String):
	if not patches.has(id):
		print("OptimisedMoves: There is no Patch %s" % id)
		return null
	return patches[id]

func run_patch_safe(patch_id:String, obj:Object, function:String, args:Array) -> bool:
	var patch: Patch = obj.get(patch_id)
	if patch == null:
		patch = get_patch(patch_id.substr(1))
		obj.set(patch_id, patch)
	if not patch.is_enabled():
		return false
	if not lib.run_safe(patch, obj, function, args):
		return false
	return true

func set_lib(lib):
	self.lib = lib
	self.lib_enabled = true

func is_lib_enabled() -> bool:
	return lib_enabled

func create_options_menu(modOptions):
	self.modOptions = modOptions
	
	menu = modOptions.generate_menu("OptimisedMoves", "Only Optimised Moves")
	
	menu.theme = load("res://OptimisedMoves/options/generic/extra.theme")
	
	# ---- HEADER ----
	var logo = menu.add_image("logo", "res://OptimisedMoves/logo.png")
	logo.texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.texture.expand = true
	logo.texture.rect_min_size = Vector2(0, 56)
	
	menu.add_label("version", "Version %s" % get_parent().version)
	
	# ---- MAIN ----
	add_padded_label(menu, "main", "Main", Label.ALIGN_LEFT, label_color)
	
	var allow_any_option = add_bool_tooltip(menu, "allow_patches", "Enable Patching", allow_any, "A global switch to toggle all patches ON and OFF")
	allow_any_option.connect("option_changed", self, "_set_allow_any_option")
	
	var use_detailed_icons_option = add_bool_tooltip(menu, "use_detailed_icons", "Use Detailed Icons", use_detailed_icons, "A switch to change only the visual icons of this menu - no gameplay affected")
	use_detailed_icons_option.connect("option_changed", self, "_set_use_detailed_icons_option")
	
	# ---- PATCHES ----
	add_padded_label(menu, "patch", "Patches", Label.ALIGN_LEFT, label_color)
	
	for patch in get_children():
		if patch.info.requires.empty():
			patch.generate_symbol_option(menu)
	
	# ---- EXTRA ----
	add_padded_label(menu, "extra", "Extra", Label.ALIGN_LEFT, label_color)
	
	var allow_denied_option = add_bool_tooltip(menu, "allow_denied_patches", "Enter the Dangerzone", allow_denied, "Allows to turn on experimental, highly unstable or previously crashed patches")
	allow_denied_option.connect("option_changed", self, "_set_allow_denied_option")
	
	var open_logs_option = menu.add_button("open_logs_option", "Logs folder", "Open")
	set_tooltip(open_logs_option, "Opens the folder containing Your Only Move Is HUSTLE logs. These contain information useful for developers when solving problems")
	open_logs_option.connect("option_changed", self, "_on_open_logs_option")
	
	var latest_log_option = menu.add_button("open_logs_option", "Latest log", "Open")
	latest_log_option.connect("option_changed", self, "_on_latest_log_option")
	set_tooltip(latest_log_option, "Opens the latest log file. This file may be behind a bit - it uses a buffer. But it will be filled out when you close the game")
	
	# ---- CREDITS ----
	add_padded_label(menu, "credits", "Credits", Label.ALIGN_LEFT, label_color)
	
	menu.add_label("credits_dev", "Development: BLOODWIING", Label.ALIGN_LEFT)
	menu.add_label("credits_test", "Testing: VineRaio", Label.ALIGN_LEFT)
	menu.add_label("credits_other", "Support: fleig", Label.ALIGN_LEFT)
	
	# ---- MORE ----
	add_padded_label(menu, "more", "More updates coming soon...", Label.ALIGN_LEFT, Color(0.2, 0.2, 0.2))
	
	# ---- FINAL SETUP ----
	modOptions.add_menu(menu)
	
	for patch in get_children():
		patch.finalise_symbol_option()
	
	_set_use_detailed_icons_option("", use_detailed_icons)
	
	for patch in get_children():
		patch.post_menu_callback()
	
	return menu

func add_padded_label(menu, name, text, align=Label.ALIGN_CENTER, color=Color.white):
	var label = menu.add_label(name, text, align, color)
	label.label.theme_type_variation = "PaddedLabel"
	return label

func add_bool_tooltip(menu, name, text, default:=false, tooltip=null):
	var opt = menu.add_bool(name, text, default)
	if tooltip:
		set_tooltip(opt, tooltip)
	return opt

func set_tooltip(item, text):
	item.use_custom_tooltip = true
	item.custom_tooltip = preload("res://OptimisedMoves/options/generic/RichTextTooltip.gd")
	item.hint_tooltip = text

func _set_use_detailed_icons_option(path, value):
	use_detailed_icons = value
	for patch in get_children():
		if patch.symbol_option == null:
			continue
		patch.symbol_option.btn.use_detailed_symbol = value

func _set_allow_any_option(path, value):
	allow_any = value
	for patch in get_children():
		patch.update_symbol_option()

func _set_allow_denied_option(path, value):
	allow_denied = value
	for patch in get_children():
		patch.update_symbol_option()

func _on_open_logs_option(path, value):
	OS.shell_open(ProjectSettings.globalize_path("user://logs"))

func _on_latest_log_option(path, value):
	OS.shell_open(ProjectSettings.globalize_path("user://logs/godot.log"))
