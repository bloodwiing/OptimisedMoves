extends "res://modloader/MLMainHook.gd"


func _ready():
	ModLoader.get_node("OptimisedMoves").call("_late_init")
