extends "res://SoupModOptions/OptionTypes/ModOptionObject.gd"


const SubItemContainer := preload("res://OptimisedMoves/options/generic/SubItemContainer.gd")

var container:SubItemContainer

var content_list = []

var root_option


func _build():
	container = SubItemContainer.new()
	container.set_theme_type_variation("OptionList")
	container.name = "SubItemContainer"
	.add_child(container)

func _ready():
	pass

func has_node(path:NodePath):
	return container.has_node("SubItem_%s" % path.get_name(0))

func add_child(node:Node, legible_unique_name:bool = false):
	var sub_item = container.add_item(node)
	sub_item.name = "SubItem_%s" % node.name
	content_list.append(sub_item.get_node("Contents"))
	node.set_parent_option(root_option)
