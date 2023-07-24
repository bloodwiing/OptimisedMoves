extends "res://Custom.gd"


var OptimisedMoves = null setget , _get_optimised_moves


func _get_optimised_moves():
	if OptimisedMoves == null:
		OptimisedMoves = ModLoader.get_node("OptimisedMoves")
	return OptimisedMoves
