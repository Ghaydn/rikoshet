extends Node2D

#
#This node allows to edit a "pole"
#Without it one cannot even launch balls

var mouse_pos: Vector2
var mouse_on_pole: Vector2
onready var painter = $painter

var fig_cell: Vector2 = Vector2.ZERO
var painter_mode: String
var emitter_dir: int
var emitter_speed: int = 5
var press_pos: Vector2
var touch_drag: bool
var edit_text: bool

var painter_desc: CellDesc

func _ready():
	if g.editor == null: g.editor = self
	painter_desc = CellDesc.new()


func _unhandled_input(event):
	
	if edit_text:
		if event.is_action_released("place"):
			for child in g.pole.get_children():
				if child.has_method("hide_editor"): child.hide_editor()
		return
	mouse_pos = get_global_mouse_position()
	mouse_on_pole = g.pole.get_cell_coord(mouse_pos)
	
	if event is InputEventScreenDrag:
		if event.relative.length()>2:
			touch_drag = true

	if Input.is_action_just_pressed("quicksave"):
		g.quicksave()
	
	if Input.is_action_just_pressed("quickload"):
		g.quickload()
		
	if Input.is_action_just_pressed("clear"):
		g.pole.clear_pole()
	
	if event is InputEventMouseMotion:
		painter.position = g.pole.to_center(mouse_on_pole)
	
	if not Input.is_action_pressed("ctrl"):
		if Input.is_action_just_pressed("scroll_up"):
			if Input.is_action_pressed("shift"):
				if painter.visible:
					button_next_fig()
			else:
				if painter.visible:
					button_rotate_right()
		if Input.is_action_just_pressed("scroll_down"):
			if Input.is_action_pressed("shift"):
				if painter.visible:
					button_prev_fig()
			else:
				if painter.visible:
					button_rotate_left()
		
		
		if event.is_action_pressed("place"):
			press_pos = g.pole.to_center(mouse_on_pole)
			if not event is InputEventScreenTouch: touch_drag = false
			
		if event.is_action_released("place"):
			if not touch_drag:
				painter.position = g.pole.to_center(mouse_on_pole)
				if painter.visible: use_painter()
				else:
					var emitt = g.pole.find_emitter(mouse_on_pole)
					if emitt != null: emitt.emit_ball()
					var txt = g.pole.find_text(mouse_on_pole)
					if txt != null: txt.open_editor()
				g.interface.hide_mixer()
			if event is InputEventScreenTouch: touch_drag = false

		if Input.is_action_pressed("erase"):
			painter.position = g.pole.to_center(mouse_on_pole)
			if painter.visible: use_eraser()
		

		if Input.is_action_just_pressed("scroll_up"):
			if Input.is_action_pressed("shift"):
				if not painter.visible:
					g.pole.backup_enabled = false
					g.pole.shift_selected_cell(mouse_on_pole, true)
			else:
				if not painter.visible:
					g.pole.backup_enabled = false
					g.pole.rotate_selected_cell(mouse_on_pole, false)
				
		if Input.is_action_just_pressed("scroll_down"):
			if Input.is_action_pressed("shift"):
				if not painter.visible:
					g.pole.backup_enabled = false
					g.pole.shift_selected_cell(mouse_on_pole, false)
			else:
				if not painter.visible:
					g.pole.backup_enabled = false
					g.pole.rotate_selected_cell(mouse_on_pole, true)
	
	if event.is_action_pressed("ui_cancel"):
		if g.help_panel.visible: g.help_panel.hide_help()
		elif painter.visible: g.interface.hide_palette()
		else: g.quit()
	
	if event.is_action_pressed("show_palette"):
		g.interface.showhide_palette()
	
	if event.is_action_pressed("launch_all"):
		button_go()
	
	if event.is_action_pressed("help"):
		g.interface.button_help()
	
	if event.is_action_pressed("killballs"):
		button_killballs()
	
	if event.is_action_pressed("erase_all"):
		button_clear()
	

func use_painter():
	if not painter.visible: return
	match painter_mode:
		"eraser": use_eraser()
		"eater": place_eater()
		"emitter": place_emitter()
		"placer": place_fig()
		"text": place_text()
		"pipette": pipette()
	g.pole.backup_enabled = false

func use_eraser():
	if not painter.visible: return
	var paint_pos = g.pole.get_cell_coord(painter.position)
	g.pole.erase_cell(paint_pos)
	
	var eater = g.pole.find_eater(paint_pos)
	if eater != null: eater.queue_free()
	var emitter = g.pole.find_emitter(paint_pos)
	if emitter != null: emitter.queue_free()
	var text = g.pole.find_text(paint_pos)
	if text != null: text.queue_free()
	g.pole.backup_enabled = false

func place_eater():
	if not painter.visible: return
	var paint_pos = g.pole.get_cell_coord(painter.position)
	use_eraser()
	var ea = r.eater.instance()
	g.pole.add_child(ea)
	ea.position = g.pole.to_center(paint_pos)
	g.pole.backup_enabled = false

func place_emitter():
	if not painter.visible: return
	var paint_pos = g.pole.get_cell_coord(painter.position)
	use_eraser()
	var em = r.emitter.instance()
	g.pole.add_child(em)
	em.position = g.pole.to_center(paint_pos)
	em.set_dir(emitter_dir)
	em.set_speed(emitter_speed * g.MIN_SPEED)
	g.pole.backup_enabled = false

func place_fig():
	if not painter.visible: return
	var paint_pos = g.pole.get_cell_coord(painter.position)
	use_eraser()
	g.pole.set_cell_type(paint_pos, fig_cell)
	g.pole.backup_enabled = false

func place_text():
	if not painter.visible: return
	var paint_pos = g.pole.get_cell_coord(painter.position)
	var text = g.pole.find_text(paint_pos)
	if text != null:
		text.open_editor()
	else:
		use_eraser()
		var txt = r.text.instance()
		g.pole.add_child(txt)
		txt.position = g.pole.to_center(paint_pos)
		txt.open_editor()
		g.pole.backup_enabled = false
	

func pipette():
	if not painter.visible: return
	var paint_pos = g.pole.get_cell_coord(painter.position)
	var cell_type = g.pole.get_cell_type(paint_pos)
	
	
	if cell_type.x == -1 or cell_type.y == -1:
		var eater = g.pole.find_eater(paint_pos)
		if eater != null: button_eater()
		var emitter = g.pole.find_emitter(paint_pos)
		if emitter != null: button_emitter()
		var text = g.pole.find_text(paint_pos)
		if text != null: button_text()
	else:
		var desc = g.cd.tilemap_to_palette(cell_type)
		set_painter(desc)


func button_eater():
	painter_mode = "eater"
	painter.rotation_degrees = 0
	painter.scale = Vector2(1, 1)
	painter.visible = true
	painter.texture = r.eater_image

func button_emitter():
	painter_mode = "emitter"
	painter.rotation_degrees = emitter_dir * 90
	painter.scale = Vector2(1, 1)
	painter.visible = true
	painter.texture = r.emitter_image

func show_painter():
	painter_mode = "placer"
	painter.rotation_degrees = 0
	painter.scale = Vector2(1, 1)
	painter.visible = true

func hide_painter():
	painter.visible = false
	painter.texture = r.tilemap_image

func toggle_painter():
	if painter.visible: hide_painter()
	else: show_painter()

func button_erase():
	painter_mode = "eraser"
	painter.rotation_degrees = 0
	painter.scale = Vector2(1, 1)
	painter.visible = true
	painter.texture = r.eraser_image

func button_pipette():
	painter_mode = "pipette"
	painter.rotation_degrees = 0
	painter.scale = Vector2(1, 1)
	painter.visible = true
	painter.texture = r.pipette_image

func button_text():
	painter_mode = "text"
	painter.rotation_degrees = 0
	painter.scale = Vector2(1, 1)
	painter.visible = true
	painter.texture = r.text_image

func button_rotate_right():
	if painter_mode == "emitter":
		emitter_dir = wrapi(emitter_dir + 1, 0, 4)
		painter.rotation_degrees = emitter_dir * 90
	elif painter_mode == "placer":
		set_painter(g.cd.rotate_cell(painter_desc, false))

func button_rotate_left():
	if painter_mode == "emitter":
		emitter_dir = wrapi(emitter_dir - 1, 0, 4)
		painter.rotation_degrees = emitter_dir * 90
	elif painter_mode == "placer":
		set_painter(g.cd.rotate_cell(painter_desc, true))

func button_next_fig():
	if painter_mode == "emitter":
# warning-ignore:narrowing_conversion
		emitter_speed = clamp(emitter_speed + 1, 1, 10)
		g.interface.set_emitter_color(Color.from_hsv(0, float(emitter_speed) / 10, 1.0))
	elif painter_mode == "placer":
		set_painter(g.cd.shift_cell(painter_desc, true))
		

func button_prev_fig():
	if painter_mode == "emitter":
# warning-ignore:narrowing_conversion
		emitter_speed = clamp(emitter_speed - 1, 1, 10)
		g.interface.set_emitter_color(Color.from_hsv(0, float(emitter_speed) / 10, 1.0))
	elif painter_mode == "placer":
		set_painter(g.cd.shift_cell(painter_desc, false))

func button_select_fig(pos: Vector2):
	var desc = CellDesc.new()
	desc.desc(pos, g.interface.palette_flag, g.interface.palette_doubled, g.interface.palette_reversed, g.interface.palette_rotation)
	set_painter(desc)

func set_painter(desc: CellDesc):
	painter_desc = desc
	update_painter()

func update_painter():
	fig_cell = g.cd.palette_to_tilemap(painter_desc)
	painter_mode = "placer"
	painter.texture = g.pole.get_tile_texture(fig_cell)


func button_go():
	g.pole.launch_all()

func button_killballs():
	for child in g.pole.get_children():
		if child.has_method("disappear"): child.disappear()
	

func button_clear():
	g.set_current_file("")
	g.pole.clear_pole()
