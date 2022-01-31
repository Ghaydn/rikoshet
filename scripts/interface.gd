extends Control

onready var pause_button = $settings_panel/pause
onready var mute_sound_button = $settings_panel/mixer/mute_sounds
onready var mute_music_button = $settings_panel/mixer/mute_music
onready var sound_vol = $settings_panel/mixer/volume_sounds
onready var music_vol = $settings_panel/mixer/volume_music
onready var cam_button = $settings_panel/cam
onready var emitter_button = $palette_panel/emitter
onready var mixer = $settings_panel/mixer
onready var infotext = $Infotext
onready var infotween = $Infotext/infotween

onready var button_flag = $palette_panel/set_flag
onready var button_double = $palette_panel/set_double
onready var button_reversed = $palette_panel/set_reversed


var palette_flag: bool
var palette_doubled: bool
var palette_reversed: bool
var palette_rotation: int


func _ready():
	if g.interface == null: g.interface = self
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		$settings_panel/exit.visible = false
	$palette_panel.visible = false

func to_pause():
	pause_button.texture_normal = r.play_image

func to_unpause():
	pause_button.texture_normal = r.pause_image

func to_mute():
	mute_sound_button.texture_normal = r.mute_image

func to_unmute():
	mute_sound_button.texture_normal = r.speaker_image

#func set_emitter_rotation(rot: int):
#	pass

func set_emitter_color(col: Color):
	emitter_button.modulate = col

func showhide_panel():
	$settings_panel.visible = $showhide_panel.pressed
	if $showhide_panel.pressed: $showhide_panel.rect_position.y = $settings_panel.rect_position.y - $settings_panel.rect_size.y
	else: $showhide_panel.rect_position.y = $settings_panel.rect_position.y
	hide_mixer()

func showhide_palette():
	if $palette_panel.visible:
		hide_palette()
	else: 
		show_palette()

func show_palette():
	update_palette()
	$palette_panel.visible = true
	$showhide_palette.pressed = true
	g.interface.hide_mixer()
	
func hide_palette():
	g.editor.hide_painter()
	$palette_panel.visible = false
	$showhide_palette.pressed = false
	g.interface.hide_mixer()

func update_palette():
	for x in range(4):
		for y in range(4):
			var node: TextureButton = get_node("palette_panel/palette/x" + String(x) + "y" + String(y))
			var desc = CellDesc.new()
			desc.desc(Vector2(x, y), palette_flag, palette_doubled, palette_reversed, palette_rotation)
			var pos = g.cd.palette_to_tilemap(desc)
			node.texture_normal = g.pole.get_tile_texture(pos)
	if palette_flag:
		if palette_doubled:
			if palette_reversed:
				var desc = CellDesc.new()
				desc.desc(Vector2(1, 0), false, true, true, 0)
				button_flag.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc)) 
				desc.desc(Vector2(0, 0), true, false, true, 0)
				button_double.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
				desc.desc(Vector2(1, 0), true, true, false, 0)
				button_reversed.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
			else:
				var desc = CellDesc.new()
				desc.desc(Vector2(1, 0), false, true, false, 0)
				button_flag.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc)) 
				desc.desc(Vector2(0, 1), true, false, false, 0)
				button_double.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
				desc.desc(Vector2(1, 0), true, true, true, 0)
				button_reversed.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
		else:
			if palette_reversed:
				var desc = CellDesc.new()
				desc.desc(Vector2(0, 0), false, false, true, 0)
				button_flag.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc)) 
				desc.desc(Vector2(1, 0), true, true, true, 0)
				button_double.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
				desc.desc(Vector2(0, 1), true, false, false, 0)
				button_reversed.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
			else:
				var desc = CellDesc.new()
				desc.desc(Vector2(0, 1), false, false, false, 0)
				button_flag.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc)) 
				desc.desc(Vector2(1, 0), true, true, false, 0)
				button_double.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
				desc.desc(Vector2(0, 0), true, false, true, 0)
				button_reversed.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
	else:
		if palette_doubled:
			if palette_reversed:
				var desc = CellDesc.new()
				desc.desc(Vector2(1, 0), true, true, true, 0)
				button_flag.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc)) 
				desc.desc(Vector2(0, 0), false, false, true, 0)
				button_double.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
				desc.desc(Vector2(1, 0), false, true, false, 0)
				button_reversed.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
			else:
				var desc = CellDesc.new()
				desc.desc(Vector2(1, 0), true, true, false, 0)
				button_flag.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc)) 
				desc.desc(Vector2(0, 1), false, false, false, 0)
				button_double.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
				desc.desc(Vector2(1, 0), false, true, true, 0)
				button_reversed.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
		else:
			if palette_reversed:
				var desc = CellDesc.new()
				desc.desc(Vector2(0, 0), true, false, true, 0)
				button_flag.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc)) 
				desc.desc(Vector2(1, 0), false, true, true, 0)
				button_double.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
				desc.desc(Vector2(0, 1), false, false, false, 0)
				button_reversed.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
			else:
				var desc = CellDesc.new()
				desc.desc(Vector2(0, 1), true, false, false, 0)
				button_flag.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc)) 
				desc.desc(Vector2(1, 0), false, true, false, 0)
				button_double.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))
				desc.desc(Vector2(0, 0), false, false, true, 0)
				button_reversed.texture_normal = g.pole.get_tile_texture(g.cd.palette_to_tilemap(desc))

func showhide_navigation():
	$navigation_panel.visible = not $showhide_navigation.pressed
	g.interface.hide_mixer()

func darken(col: Color):
	for child in $palette_panel.get_children():
		if child.pause_mode != Node.PAUSE_MODE_PROCESS:
			child.modulate = col
	$palette_panel.self_modulate = col
	$navigation_panel.self_modulate = col
	$settings_panel.self_modulate = col
	mixer.self_modulate = col



func button_help():
	g.help_panel.show_help()

func button_rotate_right():
	palette_rotation = (palette_rotation + 3) % 4
	update_palette()

func button_rotate_left():
	palette_rotation = (palette_rotation + 1) % 4
	update_palette()

func hide_mixer():
	g.save_settings()
	mixer.visible = false
	$settings_panel/show_mixer.pressed = false

func toggle_mixer():
	if mixer.visible: hide_mixer()
	else:
		$settings_panel/mixer/volume_sounds.value = db2linear(AudioServer.get_bus_volume_db(2))
		$settings_panel/mixer/volume_music.value = db2linear(AudioServer.get_bus_volume_db(1))
		$settings_panel/mixer.visible = true

func show_infotext(data: String):
	if infotext.modulate.a > 0.1: infotext.text += data
	else: infotext.text = data
	infotext.visible = true
	#infotext.modulate.a = 1.0
	
	infotween.interpolate_property(infotext, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2.0)
	infotween.start()

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func infotween_completed():
	infotext.visible = false
	infotext.text = ""


