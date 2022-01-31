extends TileMap
#In fact, this is not a pole, but a field,
#it's just that I'm used to calling it in all my programs

onready var s1 = $sounds/sound1
onready var s2 = $sounds/sound2
var backup_coords: Array
var backup_cells: Array
var backup_enabled: bool

func _ready():
	g.pole = self
	g.cs = cell_size

func hit_cell(cell_coord: Vector2, dir: int):
	var cell = get_cell_type(cell_coord)
	if get_cellv(cell_coord) == INVALID_CELL: return
	if not(cell is Vector2): return
	s1.global_position = to_center(cell_coord)
	s2.global_position = to_center(cell_coord)
	set_cell_type(cell_coord, g.cd.change_cell(cell, dir))
	return g.cd.change_direction(cell, dir)

#this function rotates a specific cell on the field, by coordinates.
#in fact it just calls the following
func rotate_selected_cell(coord: Vector2, right: bool = true):
	var emitt = find_emitter(coord)
	if emitt != null:
		if right: emitt.set_dir(emitt.direction + 3)
		else: emitt.set_dir(emitt.direction + 1)
		return
	if get_cellv(coord) == INVALID_CELL: return
	var cell_type = get_cell_type(coord)
	var new_type = g.cd.rotate_cell_tilemap(cell_type, right)
	set_cell_type(coord, new_type)


#this function changes the type of a specific cell on the field, by coordinates.
#actually just calls the following
func shift_selected_cell(coord: Vector2, forward: bool = true):
	var emitt = find_emitter(coord)
	if emitt != null:
		if forward: emitt.set_speed(emitt.ball_speed + 100)
		else: emitt.set_speed(emitt.ball_speed - 100)
		return
	if get_cellv(coord) == INVALID_CELL: return
	var cell_type = get_cell_type(coord)
	var new_type = g.cd.shift_cell_tilemap(cell_type, forward)
	set_cell_type(coord, new_type)



#aliases so that we can replace the field module with a non-tilemap
#In the name of duck-typing!
func get_cell_coord(pos: Vector2) -> Vector2:
	return world_to_map(pos)

func get_cell_type(coord: Vector2) -> Vector2:
	if get_cellv(coord) == -1: return Vector2(-1, -1)
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
	return get_cell_autotile_coord(coord.x, coord.y)
	

func set_cell_type(coord: Vector2, type: Vector2):
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
	set_cell(coord.x, coord.y, 0, false, false, false, type)

func erase_cell(coord: Vector2):
	set_cellv(coord, -1)

func to_center(pos: Vector2) -> Vector2:
	return map_to_world(pos) + cell_size / 2

func has_something(coord: Vector2) -> bool:
	return get_cellv(coord) != INVALID_CELL

func get_rect():
	var R: Rect2 = get_used_rect()
	R.position += Vector2(-10, -10)
	R.size += Vector2(20, 20)
	return R
#that's all aliases


#find the emitter in the specified coordinates using duck typing
func find_emitter(coord: Vector2):
	return find_any("emit_ball", coord)

#we also find the eater.
func find_eater(coord: Vector2):
	return find_any("eat_ball", coord)

func find_text(coord: Vector2):
	return find_any("set_text", coord)

func find_any(method: String, coord: Vector2):
	for child in get_children():
		if child.has_method(method):
			if child.position.x >= coord.x * cell_size.x and \
			child.position.y >= coord.y * cell_size.y and \
			child.position.x < (coord.x + 1) * cell_size.x and \
			child.position.y < (coord.y + 1) * cell_size.y:
				return child
	return null

#an alias for clearing a tileset, at the same time deleting other game objects#
func clear_pole():
	backup_enabled = false
	clear()
	#g.set_current_file("")
	g.cam.global_position = Vector2.ZERO
	for child in get_children():
		if child.has_method("emit_ball") or \
		child.has_method("eat_ball") or \
		child.has_method("set_text"):
			child.queue_free()
		if child.has_method("disappear"):
			child.disappear()

func launch_all():
	for child in get_children():
		if child.has_method("emit_ball"):
			child.emit_ball()

func make_backup():
	var cells = get_used_cells()
	backup_coords.clear()
	backup_cells.clear()
	for cell in cells:
		backup_coords.append(cell)
		backup_cells.append(get_cell_type(cell))
	backup_enabled = true

func restore_from_backup():
	clear()
	for i in range(backup_coords.size()):
		set_cell_type(backup_coords[i], backup_cells[i])

func count_balls():
	var count: int = 0
	for child in get_children():
		if child.has_method("disappear") and not child.is_queued_for_deletion(): count += 1
	return count

func get_tile_texture(pos: Vector2):
	var tileset_atlas: AtlasTexture = AtlasTexture.new()
	tileset_atlas.set_atlas(r.tilemap_image)
	var rect = Rect2(pos.x*g.cs.x, pos.y*g.cs.y, g.cs.x, g.cs.y)
	tileset_atlas.region = rect
	
	return tileset_atlas
