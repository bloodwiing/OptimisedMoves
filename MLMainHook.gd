extends "res://modloader/MLMainHook.gd"


func _ready():
	call_deferred("_opti_moves_init")


func _opti_moves_init():
	var OptimisedMoves = ModLoader.get_node("OptimisedMoves")
	
	OptimisedMoves._late_init()
