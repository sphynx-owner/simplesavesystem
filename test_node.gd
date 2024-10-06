extends Node2D
class_name TestNode

func _ready():
	add_to_group("savable_nodes")

func _save_item(data : ItemSaveDataResource):
	data.data["position"] = global_position

func _load_item(data : ItemSaveDataResource):
	global_position = data.data["position"]
