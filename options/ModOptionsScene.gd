extends "res://SoupModOptions/ModOptionsScene.gd"


const TreeOption = preload("res://OptimisedMoves/options/TreeOption.gd")


func _ready():
	clean_up_settings_format()

func add_symbol_bool(internal_name, label, default:bool=false):
	var node = _create_generic(preload("res://OptimisedMoves/options/SymbolOption.gd"), internal_name, label, default)
	
	_add_to_list(internal_name, node)
	node.connect("option_changed", self, "option_changed")
	return node

func add_image(internal_name, image, stretch=TextureRect.STRETCH_KEEP_CENTERED):
	var node = _create_generic(preload("res://OptimisedMoves/options/ImageOption.gd"), internal_name, image, 0)
	node.stretch = stretch
	
	_add_to_list(internal_name, node)
	return node

func add_button(internal_name, label_text, button_text):
	var node = _create_generic(preload("res://OptimisedMoves/options/ButtonOption.gd"), internal_name, label_text, button_text)
	
	_add_to_list(internal_name, node)
	return node

func _add_to_list(internal_name:String, node):
	._add_to_list(internal_name, node)
	
	var real_path = ""
	var path_parts = internal_name.split("/")
	while path_parts.size() > 1:
		var part = path_parts[0]
		path_parts.remove(0)
		var resolved = _resolve_slash_path(real_path+part+"/search")
		if resolved is TreeOption:
			real_path += "tree_"+part+"/"
		else:
			real_path += part+"/"
	node.fullpath = real_path+path_parts[0]

func _resolve_slash_path(string:String):
	var fullstring := "OptionList/"+string
	var path_parts := fullstring.split("/")
	var current_path := ""
	for p_index in path_parts.size():
		var p = path_parts[p_index]
		
		if p == path_parts[path_parts.size()-1]:
			break
		var prefix = ("/" if p != path_parts[0] else "")
		var temp_path = current_path+prefix+p
		var node = get_node_or_null(temp_path)
		
		if node == null:
			return null
		
		if node is option_types.Category:
			temp_path += "/CategoryContainer/OptionsContainer/OptionList"
		elif node is TreeOption:
			if path_parts.size() > 1 and p != path_parts[path_parts.size() - 2]:
				temp_path += "/SubItemContainer/SubItem_%s/Contents" % path_parts[p_index+1]
		elif p != path_parts[0]:
			temp_path = current_path+prefix+"tree_"+p
			var tree_node = get_node_or_null(temp_path)
			if tree_node == null:
				tree_node = _create_generic(TreeOption, "tree_" + p, "TreeOption", true)
				tree_node.root_option = node
				node.get_parent().add_child_below_node(node, tree_node)
			if path_parts.size() > 1 and p != path_parts[path_parts.size() - 2]:
				temp_path += "/SubItemContainer/SubItem_%s/Contents" % path_parts[p_index+1]
		
		current_path = temp_path
	return get_node(current_path)

func _generate_default_schema(optionlist_node=$OptionList, path=""):
	for option in optionlist_node.get_children():
		var pref = "/" if path != "" else ""
		var success_path = path+pref+option.internal_name
		if option.ignore:
			continue
		elif option is option_types.Category:
			ModOptions._slash_path_dict(default_schema, success_path)[option.internal_name] = {}
			ModOptions._slash_path_dict(nodes, success_path)[option.internal_name] = {"self":option}

			_generate_default_schema(option.get_node("CategoryContainer/OptionsContainer/OptionList"), success_path)
			continue
		elif option is TreeOption:
			ModOptions._slash_path_dict(default_schema, success_path)[option.internal_name] = {}
			ModOptions._slash_path_dict(nodes, success_path)[option.internal_name] = {"self":option}

			for content in option.content_list:
				_generate_default_schema(content, success_path)
			continue
		ModOptions._slash_path_dict(default_schema, success_path)[option.name] = option.default_value
		ModOptions._slash_path_dict(nodes, success_path)[option.name] = option
#	print(name+" schema: "+String(default_schema))

func clean_up_settings_format():
	var dir:Directory = Directory.new()
	dir.open("user://")
	var file:File = File.new()
	var filepath = ModOptions.get_file_path(name)
	var existing_data
	
	var schema = default_schema
	if not dir.dir_exists("modoptions"):
		dir.make_dir("modoptions")
	if not file.file_exists(filepath):
		existing_data = schema.duplicate(true)
	else:
		file.open(filepath, File.READ)
		existing_data = parse_json(file.get_as_text())
		if not (existing_data is Dictionary):
			dir.remove(filepath)
			existing_data = schema.duplicate(true)
	
	mirror_schema(existing_data, schema)
	file.open(filepath, File.WRITE)
	file.store_string(JSON.print(existing_data,"\t"))

func mirror_schema(output:Dictionary, schema:Dictionary):
	for key in schema:
		if schema[key] is Dictionary:
			if not (key in output) or not (output[key] is Dictionary):
				output[key] = {}
			mirror_schema(output[key], schema[key])

func item_added(internal_name, node):
	emit_signal("item_added", internal_name, node)
