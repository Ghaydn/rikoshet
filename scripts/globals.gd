extends Node

var pole: Node2D
var cs: Vector2

var editor
var cam
var interface
var saveload_dialogs
var help_panel
var music
var cd # for Cell Data

const MIN_SPEED = 200.0
const MAX_SPEED = 2000.0
#const SPEED_STEP = (MAX_SPEED - MIN_SPEED) / 10
const project_version = "0.8"


#var mute_audio: bool
var current_file

var fullscreen: bool

func quit():
	save_settings()
	get_tree().quit()


func set_fullscreen(value: bool):
	fullscreen = value
	var buttn = interface.get_node("settings_panel/fullscreen")
	buttn.pressed = fullscreen
	OS.window_fullscreen = value

#exactly turns off or exactly turns on the sound
func set_mute(yes: bool = true):
	if yes != AudioServer.is_bus_mute(2): toggle_mute_sounds()
	interface.mute_sound_button.pressed = yes

func set_sound_volume(value: float):
	var new_value = linear2db(value)
	AudioServer.set_bus_volume_db(2, new_value)
	interface.sound_vol.value = value

#toggles the sound
func toggle_mute_sounds():
	var muted = not AudioServer.is_bus_mute(2)
	AudioServer.set_bus_mute(2, muted)
	g.interface.mute_sound_button.pressed = muted

#same with pause
func set_pause(yes: bool = true):
	if yes != get_tree().paused: pause()

func pause():
	if get_tree().paused:
		pole.modulate = Color.from_hsv(0, 0, 1)
		interface.darken(Color.from_hsv(0, 0, 1))
		get_tree().paused = false
		if editor != null:
			interface.to_unpause()
	else:
		pole.modulate = Color.from_hsv(0, 0, 0.5)
		interface.darken(Color.from_hsv(0, 0, 0.5))
		get_tree().paused = true
		if editor != null:
			interface.to_pause()
	# = editor.pause.normal


func quicksave():
	var icon = get_viewport().get_texture().get_data()
	icon.flip_y()
	if current_file != null: save_to_file(current_file, save_to_res(), icon)


func quickload():
	if current_file == null: return
	var data = load_from_file(current_file)
	if data:
		load_from_res(data)
		
#I like the resource-saver more than JSON, since it works
#natively with GODOT types. Less crutches.
func save_to_file(filename: String, data: pole_save, img: Image = null):
	var error = ResourceSaver.save(filename, data)
	if error == 0:
		answer("File " + filename + " saved")
		set_current_file(filename)
		
		if img != null:
			var isize: Vector2 = img.get_size()
			var nimg: Image
			if isize.x > isize.y: nimg = img.get_rect(Rect2(isize.x/2 - isize.y/2, 0, isize.y, isize.y))
			else: nimg = img.get_rect(Rect2(0, isize.y/2 - isize.x/2, isize.y, isize.y))
			
#			if isize.x > isize.y: img.crop(isize.y, isize.y)
#			else: img.crop(isize.x, isize.x)
			nimg.resize(128, 128, 0)
# warning-ignore:return_value_discarded
			nimg.save_png(filename.get_basename() + ".png")
		
	else:
		answer("Cannot save file " + filename + ": error #" + error)

func load_from_file(filename: String) -> pole_save:
	print("Loading file "+ filename)
	var newfile = ResourceLoader.load(filename)
	if newfile == null:
		answer("ERROR: file " + filename + " missing or not a resource.")
		return null
	if not (newfile is pole_save):
		answer ("ERROR: file " + filename + " is not a saved game.")
		return null
	answer("File " + filename + " loaded")
	set_current_file(filename)
	return newfile

#This function saves all game data in one resource,
#we need to feed it to the save function to a file
func save_to_res() -> pole_save:
	var res : pole_save = pole_save.new() #the resource itself
	res.version = project_version
	#first save the tiles
	var cells = pole.get_used_cells() #vector table with occupied cells
	var cell_types = {} #we will write data here
	#use the vector table as keys and write content values to them.
	#I have not found a function to simply get this data from the tilemap
	for one_cell in cells:
		cell_types[one_cell] = pole.get_cell_type(one_cell)
	res.cell_array = cell_types #and write this data to a resource file
	
	#now find and save children
	for child in pole.get_children():
		#Emitters first
		if child.has_method("emit_ball"):
			var my_emitter = {
				"position"   : (child.position / g.cs),
				"direction"  : child.direction,
				"ball_speed" : child.ball_speed,
				"autostart"  : child.autostart,
				"autoshoot"  : false,
				"autoshoot_time" : 1}
			#the emitter may have an auto-start timer inside, we will remember it too
			for t in child.get_children():
				if t is Timer:
					if t.autostart and not t.one_shot:
						my_emitter["autoshoot"] = true
						my_emitter["autoshoot_time"] = t.wait_time
			res.ball_emitters.append(my_emitter)
		#Then the eaters
		if child.has_method("eat_ball"):
			var my_eater = {
				"position" : child.position}
			res.ball_eaters.append(my_eater)
		#Now texts
		if child.has_method("hide_editor"):
			var my_text = {
				"position" : child.position,
				"text" : child.caption.text
			}
			res.texts.append(my_text)
	#done!
	return res

#This function restores the game board from a resource
#that we usually get from a save file
func load_from_res(res: pole_save):
	#first, let's delete everything from the field.
	pole.clear_pole()
	var version = res.get("version")
	if version == null: version = "0.1"
	#else: version = float(version)
	
	#restoring tiles
	for cell_coord in res.cell_array.keys():
		pole.set_cell_type(cell_coord, res.cell_array[cell_coord])
	
	#restoring eaters
	for child in res.ball_eaters:
		var my_eater = r.eater.instance()
		pole.call_deferred("add_child", my_eater) #thread safe!
		if version == "0.3":
			my_eater.position = child["position"] / 128 * g.cs
		else:
			my_eater.position = child["position"]
	
	#restoring emitters
	var emitter_to_pos
	for child in res.ball_emitters:
		var my_emitter = r.emitter.instance()
		my_emitter.autostart = child["autostart"]
		#don't forget about auto-start timers
		if child["autoshoot"]:
			var T = Timer.new()
			my_emitter.add_child(T) #This emitter has not yet entered the tree, so we add a child to it without deferred
			T.autostart = true
			T.one_shot = false
			T.wait_time = child["autoshoot_time"]
		pole.call_deferred("add_child", my_emitter)
		if version == "0.3":
			if child.has("ball_speed"): my_emitter.set_speed(child["ball_speed"] / 2)
			my_emitter.position = child["position"] / 128 * g.cs
		else:
			if child.has("ball_speed"): my_emitter.set_speed(child["ball_speed"])
			my_emitter.position = child["position"] * g.cs
		my_emitter.set_dir(child["direction"])
		emitter_to_pos = my_emitter
	
	#now texts
	for child in res.texts:
		var my_text = r.text.instance()
		pole.call_deferred("add_child", my_text)
		my_text.position = child["position"]
		my_text.call_deferred("set_text", child["text"])
	
	#and we did not save the balls, so we will not restore them
	var rect: Rect2 = pole.get_used_rect()
	rect = Rect2(rect.position * cs, rect.size * cs)
	
	cam.global_position = rect.position + rect.size/2
	if rect.size.x > get_viewport().size.x * cam.zoom.x and \
	rect.size.y > get_viewport().size.y * cam.zoom.y:
		if emitter_to_pos != null: cam.global_position = emitter_to_pos.position

func set_current_file(filename: String):
	current_file = filename
	if filename == "": OS.set_window_title("Rikoshet - empty")
	else: OS.set_window_title("Rikoshet - " + filename.get_file().get_basename())


#---------------------------------------------------
func save_settings():
	save_settings_to_file("user://settings.tres", save_settings_to_res())

func load_settings():
	var filename = "user://settings.tres"
	var data = load_settings_from_file(filename)
	if data:
		return load_settings_from_res(data)
	return false

func save_settings_to_file(filename: String, data: settings_res):
	var error = ResourceSaver.save(filename, data)
	if error != 0:
		answer("Cannot save settings file " + filename + ": error #" + error)

func load_settings_from_file(filename: String) -> settings_res:
	print("Loading settings...")
	var newfile = ResourceLoader.load(filename)
	if newfile == null:
		print("ERROR: settings file " + filename + " missing or not a resource.")
		return null
	if not (newfile is settings_res):
		print("ERROR: settings file " + filename + " is not a valid settings file.")
		return null
	return newfile

func save_settings_to_res() -> settings_res:
	var res : settings_res = settings_res.new()
	res.version = project_version
	
	res.sound_vol = db2linear(AudioServer.get_bus_volume_db(2))
	res.music_vol = db2linear(AudioServer.get_bus_volume_db(1))
	res.mute_sound = AudioServer.is_bus_mute(2)
	res.music_enabled = music.enabled
	res.parent_cam = cam.parented
	res.fullscreen = fullscreen
	
	return res

func load_settings_from_res(res: settings_res):
	if res == null: return false
	var version = res.get("version")
	if version == null: version = "0.1"
	
	set_sound_volume(res.sound_vol)
	music.set_volume(res.music_vol)
	set_mute(res.mute_sound)
	music.set_enabled(res.music_enabled)
	cam.reparent(res.parent_cam)
	set_fullscreen(res.fullscreen)
	
	return true

#-----------------------------------------
func answer(atext: String):
	interface.show_infotext(atext + "\n")
	print(atext)
