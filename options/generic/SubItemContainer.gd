extends VBoxContainer


const SubItem := preload("res://OptimisedMoves/options/generic/SubItem.tscn")


func add_item(node:Node):
	if get_child_count() > 0:
		var last = get_child(get_child_count() - 1)
		last.extend_guide(true)
	
	var sub := SubItem.instance()
	sub.add_child(node)
	.add_child(sub)
	return sub
