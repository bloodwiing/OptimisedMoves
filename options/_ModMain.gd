extends Node

func _init(modLoader = ModLoader):
	modLoader.installScriptExtension("res://SoupModOptions/MLMainHook.gd")
	modLoader.installScriptExtension("res://SoupModOptions/UIHook.gd")
	
	print("OptimisedMoves: Installing Mod Options extensions")
	modLoader.installScriptExtension("res://OptimisedMoves/options/ModOptionObject.gd")
	modLoader.installScriptExtension("res://OptimisedMoves/options/CheckbuttonOption.gd")
	modLoader.installScriptExtension("res://OptimisedMoves/options/OptionButtonOption.gd")
	modLoader.installScriptExtension("res://OptimisedMoves/options/ModOptionsScene.gd")

func _ready():
	pass
