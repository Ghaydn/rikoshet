extends Node


func _ready():
	if not g.load_settings():
		g.cam.reparent(true)
		var res = g.load_from_file("user://tutorial.tres")
		if res != null: g.load_from_res(res)
