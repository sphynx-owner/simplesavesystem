extends Node

const save_address : String = "user://savegame.tres"

func _ready():
	load_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

func save_game():
	print("saving")
	var all_savable_items = get_tree().get_nodes_in_group("savable_nodes")
	var save_data : GameSaveDataResource = GameSaveDataResource.new()
	
	print("all savable items: ", all_savable_items)
	
	for item in all_savable_items:
		var item_id : int = item.get_instance_id()
		var item_save_data : ItemSaveDataResource = ItemSaveDataResource.new()
		save_data.item_data[item_id] = item_save_data
		item._save_item(item_save_data)
		for node in item_save_data.nodes.keys():
			item_save_data.nodes[node] = item_save_data.nodes[node].get_instance_id()
		item_save_data.script_path = (item.get_script() as GDScript).resource_path
	
	ResourceSaver.save(save_data, save_address)

func load_game():
	if !FileAccess.file_exists(save_address):
		print("returning, no file found")
		return
	
	var loaded_game_data : GameSaveDataResource = SafeResourceLoader.load(save_address)
	
	var id_to_instance : Dictionary
	
	for item in loaded_game_data.item_data.keys():
		var script_path : String = loaded_game_data.item_data[item]["script_path"]
		
		if !script_path.contains("res://"):
			print("invalid script path, not loading element")
			continue
		
		var new_item = (load(script_path) as GDScript).new()
		id_to_instance[item] = new_item
	
	for item in loaded_game_data.item_data.keys():
		for node in loaded_game_data.item_data[item].nodes.keys():
			loaded_game_data.item_data[item].nodes[node] = id_to_instance[loaded_game_data.item_data[item].nodes[node]]
		id_to_instance[item]._load_item.call_deferred(loaded_game_data.item_data[item])
		get_tree().root.add_child.call_deferred(id_to_instance[item])
