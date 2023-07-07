extends Node


var version := "Null"

var copy_status = 1
var lib

var patchManager

var modOptions = null


func _init(modLoader = ModLoader):
	patchManager = load("res://OptimisedMoves/PatchManager.gd").new(modLoader)
	add_child(patchManager)
	
	modLoader.installScriptExtension("res://OptimisedMoves/MLMainHook.gd")
	
	name = "OptimisedMoves"

func _late_init():
	for mod in ModLoader.active_mods:
		if mod[1]["name"] == "OptimisedMoves":
			version = mod[1]["version"]
			break
	
	yield(_copy_dll(), "completed")
	
	if copy_status != OK:
		print("OptimisedMoves: Optimisations are disabled due to previous failures")
		var toast = load("res://OptimisedMoves/ui/UIToast.tscn").instance()
		toast.set_text("OptimisedMoves: There was an error, the mod is now disabled till next restart...")
		get_tree().get_current_scene().find_node("UILayer").add_child(toast)
		return
	
	var OptiMoves = ResourceLoader.load("res://OptimisedMoves/lib/optimoves.gdns").new()
	add_child(OptiMoves)
	lib = OptiMoves
	patchManager.set_lib(lib)
	
	modOptions = get_tree().get_current_scene().get_node("ModOptions")
	if modOptions:
		print("OptimisedMoves: Detected ModOptions installation, adding menu...")
		ModLoader.installScriptExtension("res://OptimisedMoves/options/ModOptionsScene.gd")
		
		patchManager.create_options_menu(modOptions)

func get_patch(resource:String):
	return patchManager.get_patch(resource)


# DLL Copying Functions from the DiscordRichPresence mod by @snazzah 

func _copy_dll():
	var dir = Directory.new()
	var file = File.new()
	
	var res_path = "res://OptimisedMoves/lib/optimoves.dll"
	var sys_path = OS.get_executable_path().get_base_dir().plus_file("optimoves.dll")
	
	if file.file_exists(sys_path):
		var their_hash = file.get_md5(sys_path)
		var our_hash = file.get_md5(res_path)
		if our_hash == their_hash:
			copy_status = OK
			yield (get_tree(), "idle_frame")
			return
		dir.remove(sys_path)
		
	yield(_try_copy_file(res_path, sys_path, dir), "completed")
	
	if copy_status == OK:
		print("OptimisedMoves: Copied file %s to YOMI directory" % "optimoves.dll")
	else:
		print("OptimisedMoves: Error while copying file %s to YOMI: %d" % ["optimoves.dll", copy_status])

# For some users, dir.copy gives an ERR_FILE_EOF, and sometimes trying again fixes it
# This is so fucking stupid though, why does that happen so much?
func _try_copy_file(from: String, to: String, dir: Directory, try = 1):
	yield (get_tree(), "idle_frame")
	yield (get_tree(), "idle_frame")
	copy_status = dir.copy(from, to)
	yield (get_tree(), "idle_frame")
	yield (get_tree(), "idle_frame")
	# If this fails 5 times, I have given up.
	
	if copy_status == OK:
		return OK
	if try >= 5:
		return copy_status
		
	if copy_status == ERR_FILE_EOF or copy_status == ERR_FILE_CORRUPT:
		return _try_copy_file(from, to, try + 1)
