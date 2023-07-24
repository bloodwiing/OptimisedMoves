extends HBoxContainer


func _ready():
	$"%Contents".set_theme_type_variation("OptionList")

func extend_guide(value:bool):
	if value:
		$"%HierarchyGuide".size_flags_vertical = SIZE_FILL
	else:
		$"%HierarchyGuide".size_flags_vertical = 0

func add_child(node:Node, legible_unique_name:bool = false):
	$"%Contents".add_child(node, legible_unique_name)
