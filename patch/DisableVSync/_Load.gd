extends "res://OptimisedMoves/patch/Patch.gd"


const FPS_OPTIONS = [
	0, 30, 60, 120, 144, 240, 300
]


var FPSLimitOption
var current_fps := 120


static func get_patch_info(info:=PatchInfo.new()) -> PatchInfo:
	info.id = "DisableVSync"
	info.name = "Disable V-Sync"
	info.description = "Disables Vertical Sync. This enables the choice for an FPS Limit"
	info.support = info.VersionSupport.new("1.7.0", "1.7.0")
	info.revision = 1
	info.needs_lib = false
	return info

func install(modLoader: ModLoader):
	pass

func _init(patchManager).(patchManager):
	connect("state_change", self, "_on_state_change")
	pass

func _ready():
	if is_enabled():
		OS.vsync_enabled = false
		refresh_fps()

func post_menu_callback():
	_on_fps_change("", FPSLimitOption.optionbutton.selected)

func generate_extra_options(menu, path:=""):
	FPSLimitOption = menu.add_dropdown_menu(path+"FPSLimitOption", "FPS Limit", 3)
	for option in FPS_OPTIONS:
		option = "Unlimited" if option == 0 else String(option)
		FPSLimitOption.add_item(option)
	FPSLimitOption.connect("option_changed", self, "_on_fps_change")

func refresh_fps():
	if not is_enabled():
		return
	Engine.target_fps = current_fps

func _on_fps_change(path, value):
	current_fps = FPS_OPTIONS[value]
	refresh_fps()

func _on_state_change(state:bool):
	if state:
		OS.vsync_enabled = false
		refresh_fps()
	else:
		Engine.target_fps = 60
		OS.vsync_enabled = true
