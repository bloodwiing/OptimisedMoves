extends Node


enum SupportState {
	UNKNOWN = 0
	
	ALLOW_OK = 0x1,
	ALLOW_WARN = 0x3,
	ALLOW_WARN_UNTESTED = 0x13,
	ALLOW_WARN_UNSTABLE = 0x23,
	ALLOW_WARN_CUSTOM = 0x83,
	
	DENY = 0x4,
	DENY_CRASH = 0x14
	DENY_SEVERE_ERROR = 0x24,
	DENY_CUSTOM = 0x84,
	
	DISABLED = 0x8,
	DISABLED_OUT_OF_VERSION = 0x18,
	DISABLED_CUSTOM = 0x88,
}


signal state_change


const PatchInfo = preload("res://OptimisedMoves/patch/PatchInfo.gd")

const symbol_icon := {
	"arrow": preload("res://OptimisedMoves/options/generic/symbol/arrow.theme"),
	"checkmark": preload("res://OptimisedMoves/options/generic/symbol/checkmark.theme"),
	"deny": preload("res://OptimisedMoves/options/generic/symbol/deny.theme"),
	"info": preload("res://OptimisedMoves/options/generic/symbol/info.theme"),
	"warning": preload("res://OptimisedMoves/options/generic/symbol/warning.theme"),
}

const common_state_reasons := {
	SupportState.ALLOW_WARN: "Patch requires further testing",
	SupportState.ALLOW_WARN_UNTESTED: "Patch has not been tested yet for the current version. Expect some bugs",
	SupportState.ALLOW_WARN_UNSTABLE: "Patch is known to cause some gameplay-affecting issues, such as incorrect results, lag or even crashes",
	SupportState.DENY_CRASH: "Patch was shutdown before it was about to cause a crash! Please report this to the developer",
	SupportState.DENY_SEVERE_ERROR: "Patch has been found to cause severe issues! Not recommended until resolved in a future update",
	SupportState.DISABLED_OUT_OF_VERSION: "Patch is no longer applicable to the current version",
}


var enabled := false
var state = SupportState.UNKNOWN
var state_reason:String = ""

var info:PatchInfo
var depends_by = []

var patchManager
var lib = null setget , get_lib

var symbol_option


static func get_patch_info(info:=PatchInfo.new()) -> PatchInfo:
	return info

func install(modLoader):
	pass

func _init(patchManager):
	self.patchManager = patchManager
	info = get_patch_info()
	name = info.id
	interpret_support_state()

func _ready():
	interpret_enabled_by_default()

func interpret_support_state():
	if info.support.hard_minimum != null and info.support.hard_minimum.version.is_gtr(patchManager.game_version):
		state = SupportState.DISABLED_OUT_OF_VERSION
		state_reason = info.support.hard_minimum.reason
		return
	
	if info.support.hard_maximum != null and patchManager.game_version.is_gtr(info.support.hard_maximum.version):
		state = SupportState.DISABLED_OUT_OF_VERSION
		state_reason = info.support.hard_maximum.reason
		return
	
	if not (patchManager.game_version.is_geq(info.support.soft_minimum) and info.support.soft_maximum.is_geq(patchManager.game_version)):
		state = SupportState.ALLOW_WARN_UNTESTED
		return
	
	state = SupportState.ALLOW_OK

func interpret_enabled_by_default():
	enabled = false
	if not is_allowed():
		return
	match state & 0xf:
		SupportState.ALLOW_OK, SupportState.ALLOW_WARN:
			set_enabled(true)

func set_support_state(state, reason:String):
	if (state & 0xf) < (self.state & 0xf):
		return
	self.state = state
	self.state_reason = reason

func get_symbol():
	match state & 0xf:
		SupportState.ALLOW_OK:
			return symbol_icon["checkmark"]
		SupportState.ALLOW_WARN:
			return symbol_icon["warning"]
		SupportState.DENY:
			return symbol_icon["deny"]
		SupportState.DISABLED:
			return symbol_icon["info"]
	return symbol_icon["info"]

func get_reason():
	if state & 0xf0 == 0x80:
		return state_reason
	var reason = common_state_reasons.get(state, "Undefined")
	if state == SupportState.DISABLED_OUT_OF_VERSION:
		reason += state_reason
	return reason

func is_allowed():
	if not patchManager.allow_any:
		return false
	
	match state & 0xf:
		SupportState.ALLOW_OK:
			return true
		SupportState.ALLOW_WARN:
			return true
		SupportState.DENY:
			return patchManager.allow_denied
		SupportState.DISABLED:
			return false

func is_enabled():
	return (patchManager.is_lib_enabled() or not info.needs_lib) and is_allowed() and enabled

func set_enabled_option(state:bool):
	if symbol_option != null:
		symbol_option.option_changed(state)
		patchManager.modOptions.save_settings(patchManager.menu.name)
	else:
		set_enabled(state)

func set_enabled(state:bool):
	if enabled != state:
		print("OptimisedMoves: Patch %s %s" % [info.id, "ENABLED" if state else "DISABLED"])
		enabled = state
		emit_signal("state_change", state)

func add_depends_by(patch):
	depends_by.append(patch)

func generate_symbol_option(menu, path:=""):
	symbol_option = menu.add_symbol_bool(path+"patch_%s" % info.id, info.name, enabled)
	symbol_option.connect("option_changed", self, "_on_option_changed")
	symbol_option.set_symbol(get_symbol())
	symbol_option.parent_behaviour_flags = 0
	symbol_option.use_custom_tooltip = true
	symbol_option.custom_tooltip = load("res://OptimisedMoves/options/generic/RichTextTooltip.gd")
	symbol_option.hint_tooltip = generate_hint_tooltip()
	
	update_symbol_option()
	
	for dependency in depends_by:
		dependency.generate_symbol_option(menu, path+"patch_%s/" % info.id)
	
	generate_extra_options(menu, path+"patch_%s/" % info.id)

func generate_extra_options(menu, path:=""):
	pass

func _on_option_changed(path, state):
	set_enabled(state)

func generate_hint_tooltip():
	var desc = info.description
	
	match state & 0xf:
		SupportState.ALLOW_WARN:
			desc += "\n\n[color=#ffb300]WARNING:[/color] " + get_reason()
		SupportState.DENY:
			desc += "\n\n[color=#ff0028]SEVERE:[/color] " + get_reason()
		SupportState.DISABLED:
			desc += "\n\n[color=#6d7691]DISABLED:[/color] " + get_reason()
	
	desc += "\n\n[color=#222]ID: %s[/color]" % info.id
	desc += "\n[color=#222]Revision: %s[/color]" % info.revision
	
	return desc

func finalise_symbol_option():
	if symbol_option == null:
		return
	
	symbol_option.parent_behaviour_flags = 3

func update_symbol_option():
	if symbol_option == null:
		return
	
	if state & 0xf == SupportState.DISABLED:
		symbol_option.set_value(false)
	
	symbol_option.set_force_disabled(not is_allowed())

func post_menu_callback():
	pass

func get_lib():
	return patchManager.lib
