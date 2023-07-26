extends Node


var version := "Null"

var copy_status = 1
var lib

var gdnatives := [
	"res://OptimisedMoves/lib/OptiMoves.tres"
]

var patchManager

var modOptions = null

var initialised_before := false
var extended_mod_options := false

var UILayer


func _init(modLoader = ModLoader):
#	for i in range(5):
#		print("res://OptimisedMoves/lib/libOptiMoves.so")
#		print(OS.get_executable_path().get_base_dir().plus_file("libOptiMoves.so"))
#		var status = Directory.new().copy("res://OptimisedMoves/lib/libOptiMoves.so", OS.get_executable_path().get_base_dir().plus_file("libOptiMoves.so"))
#		print("STATUS: %s" % status)
#	print("res://OptimisedMoves/lib/libOptiMoves.so")
#	print(OS.get_executable_path().get_base_dir().plus_file("libOptiMoves.so"))
#	var ssstatus = Directory.new().copy("res://OptimisedMoves/lib/libOptiMoves.so", OS.get_executable_path().get_base_dir().plus_file("libOptiMoves.so"))
#	print("SSSTATUS: %s" % ssstatus)
#	print("res://OptimisedMoves/lib/libOptiMoves.so")
#	print(OS.get_executable_path().get_base_dir().plus_file("libOptiMoves.so"))
#	var sssstatus = Directory.new().copy("res://OptimisedMoves/lib/libOptiMoves.so", OS.get_executable_path().get_base_dir().plus_file("libOptiMoves.so"))
#	print("SSSSTATUS: %s" % sssstatus)
#	print("res://OptimisedMoves/lib/libOptiMoves.so")
#	print(OS.get_executable_path().get_base_dir().plus_file("libOptiMoves.so"))
#	var ssssstatus = Directory.new().copy("res://OptimisedMoves/lib/libOptiMoves.so", OS.get_executable_path().get_base_dir().plus_file("libOptiMoves.so"))
#	print("SSSSSTATUS: %s" % ssssstatus)
	
	var info = get_lib_native_info("res://OptimisedMoves/lib/OptiMoves.tres")
#		copy_status = Directory.new().callv("copy", info)
#		if copy_status == OK:
#			print("OptimisedMoves: Copied file %s to YOMI directory" % info[0])
#		else:
#			print("OptimisedMoves: Error while copying file %s to YOMI: %d" % [info[0], copy_status])
	
	print("res://OptimisedMoves/lib/libOptiMoves.so")
	print(OS.get_executable_path().get_base_dir().plus_file("libOptiMoves.so"))
	var sstatus = Directory.new().copy("res://OptimisedMoves/lib/libOptiMoves.so", OS.get_executable_path().get_base_dir().plus_file("libOptiMoves.so"))
	print("SSTATUS: %s" % sstatus)
	
	change_boot_splash()
	
	modLoader.installScriptExtension("res://OptimisedMoves/extensions/Custom.gd")
	
	patchManager = load("res://OptimisedMoves/patch/PatchManager.gd").new(modLoader)
	add_child(patchManager)
	
	modLoader.installScriptExtension("res://OptimisedMoves/MLMainHook.gd")
	
	for mod in modLoader.active_mods:
		if mod[2]["name"] == "soupModOptions" and mod[2]["version"] == "1.2":
			# this is fucked
			mod[0] = ResourceLoader.load("res://OptimisedMoves/options/_ModMain.gd")
			extended_mod_options = true
		if mod[2]["name"] == "OptimisedMoves":
			version = mod[2]["version"]
	
	name = "OptimisedMoves"
	
#	_copy_lib("res://OptimisedMoves/lib/OptiMoves.tres")
#	print("COPY STATUS: %s" % copy_status)
#	if copy_status != OK:
#		return

func change_boot_splash():
	var resource: StreamTexture = load("res://OptimisedMoves/splash.png")
	if not resource:
		return
	var image := resource.get_data()
	if not image:
		return
	
	var win_size := OS.window_size
	
	var viewport := VisualServer.viewport_create()
	VisualServer.viewport_set_size(viewport, win_size.x, win_size.y)
	VisualServer.viewport_attach_to_screen(viewport, Rect2(Vector2(0, 0), win_size))
	VisualServer.viewport_set_active(viewport, true)
	
	var texture := VisualServer.texture_create_from_image(image)
	VisualServer.texture_set_flags(texture, VisualServer.TEXTURE_FLAG_MIPMAPS)
	
	var canvas := VisualServer.canvas_create()
	VisualServer.viewport_attach_canvas(viewport, canvas)
	
	var canvas_item := VisualServer.canvas_item_create()
	VisualServer.canvas_item_add_texture_rect(canvas_item, Rect2(Vector2.ZERO, win_size), texture)
	VisualServer.canvas_item_set_parent(canvas_item, canvas)
	
	VisualServer.force_draw()
	
	VisualServer.free_rid(canvas_item)
	VisualServer.free_rid(canvas)
	VisualServer.free_rid(texture)
	VisualServer.free_rid(viewport)

func _late_init():
	UILayer = get_tree().get_current_scene().find_node("UILayer")
	
	if not initialised_before:
		initialised_before = true
		
		if copy_status != OK:
			print("OptimisedMoves: Optimisations are disabled due to previous failures")
			var toast = load("res://OptimisedMoves/ui/UIToast.tscn").instance()
			toast.set_text("OptimisedMoves: There was an error, the mod is now disabled till next restart...")
			UILayer.add_child(toast)
	
	if copy_status != OK:
		return
	
	var OptiMoves = ResourceLoader.load("res://OptimisedMoves/lib/OptiMoves.gdns").new()
	add_child(OptiMoves)
	lib = OptiMoves
	patchManager.set_lib(lib)
	
	yield(get_tree(), "idle_frame")
	modOptions = get_tree().get_current_scene().get_node_or_null("ModOptions")
	
	if modOptions:
		if not extended_mod_options:
			print("OptimisedMoves: Could not extend Mod Options, please notify the developer")
		else:
			print("OptimisedMoves: Detected ModOptions installation, adding menu...")
			var menu = patchManager.create_options_menu(modOptions)
	else:
		print("OptimisedMoves: ModOptions not found. Please install it to get access to Patch options")

func run_patch_safe(patch_id:String, obj:Object, function:String, args:Array) -> bool:
	return patchManager.run_patch_safe(patch_id, obj, function, args)


# DLL Copying Functions from the DiscordRichPresence mod by @snazzah 

func get_lib_native_info(lib_path: String):
#	print("res://OptimisedMoves/lib/libOptiMoves.so")
#	print(OS.get_executable_path().get_base_dir().plus_file("libOptiMoves.so"))
#	var status = Directory.new().copy("res://OptimisedMoves/lib/libOptiMoves.so", OS.get_executable_path().get_base_dir().plus_file("libOptiMoves.so"))
#	print("2ND STATUS: %s" % status)
	
	
	var lib: GDNativeLibrary = load(lib_path)

	var config := lib.config_file

	var res_path: String = config.get_value("entry", "%s.64" % OS.get_name())
	print(res_path)
	var lib_name = res_path.get_file()
	var sys_path = OS.get_executable_path().get_base_dir().plus_file(lib_name)
	print(sys_path)
#
#	return [lib_name, [res_path, sys_path]]
	
#	var file = File.new()
	
#	if file.file_exists(sys_path):
#		var their_hash = file.get_md5(sys_path)
#		var our_hash = file.get_md5(res_path)
#		if our_hash == their_hash:
#			copy_status = OK
#			return
#		dir.remove(sys_path)

	copy_status = Directory.new().copy(res_path, sys_path)

	if copy_status == OK:
		print("OptimisedMoves: Copied file %s to YOMI directory" % lib_name)
	else:
		print("OptimisedMoves: Error while copying file %s to YOMI: %d" % [lib_name, copy_status])

# For some users, dir.copy gives an ERR_FILE_EOF, and sometimes trying again fixes it
# This is so fucking stupid though, why does that happen so much?
#func _try_copy_file(from: String, to: String, try = 1):
#	print(from)
#	print(to)
#	copy_status = Directory.new().copy(from, to)
#	# If this fails 5 times, I have given up.
#
#	if copy_status == OK:
#		return OK
#	if try >= 0:
#		return copy_status
#
#	if copy_status == ERR_FILE_EOF or copy_status == ERR_FILE_CORRUPT:
#		return _try_copy_file(from, to, try + 1)
