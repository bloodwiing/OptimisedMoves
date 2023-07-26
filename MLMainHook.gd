extends "res://modloader/MLMainHook.gd"


func _ready():
	ModLoader.get_node("OptimisedMoves").call_deferred("_late_init")
