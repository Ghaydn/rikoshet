extends Node

var s1: AudioStreamPlayer2D
var s2: AudioStreamPlayer2D

func _ready():
	g.cd = self
	s1 = get_node("../sounds/sound1")
	s2 = get_node("../sounds/sound2")


#this function answers in which direction the ball will fly
#when it hits a given figure in a given direction
func change_direction(cell: Vector2, dir: int) -> int:
	if dir < 0 or dir >= 4: dir = wrapi(dir, 0, 4) #cutout
	
	var shift = int(cell.x) % 4 #clockwise direction shift
	var dir_matrix: PoolIntArray #4-way offset matrix
	#a limited number of these matrices.
	var matrix_1_triangle = f.array4x(-1, 1, 0, 0)
	var matrix_1_flag = f.array4x(2, 0, 0, 0)
	var matrix_1b_triangle = f.array4x(1, 0, 0, -1)
	var matrix_2_1 = f.array4x(2, 1, 0, -1)
	var matrix_2_2 = f.array4x(2, 1, 0, 0)
	var matrix_2_3 = f.array4x(2, 0, 0, -1)
	
	#now we look at the position of the figure in the tileset and select the matrix
	if cell.y < 4:
		if cell.x < 4 or (cell.x >= 8 and cell.x < 16):
			dir_matrix = matrix_1_triangle
		elif (cell.x >= 4 and cell.x < 8) or (cell.x >= 16 and cell.x < 20):
			dir_matrix = matrix_1_flag
		elif (cell.x >= 20 and cell.x < 24):
			dir_matrix = matrix_2_1
		elif (cell.x >= 24 and cell.x < 28):
			dir_matrix = matrix_2_2
		elif (cell.x >= 28 and cell.x < 32):
			dir_matrix = matrix_2_3
		elif cell.x >= 32 and cell.x < 36:
			if int(cell.y) == 1:
				return dir
			else:
				dir_matrix = matrix_1_triangle
		elif cell.x >= 36 and cell.x < 40:
			if int(cell.y) == 1:
				return dir
			else:
				dir_matrix = matrix_1_flag
		else:
			return dir
	else:
		if cell.x >= 8 and cell.x < 20:
			if cell.x >= 12 and cell.x < 16:
				dir_matrix = matrix_1_flag
			else:
				dir_matrix = matrix_1b_triangle
		else:
			return dir
	
	#and apply a matrix to the direction value by adding an offset
	dir = wrapi(dir + dir_matrix[(dir + shift) % 4], 0, 4)
	return dir

#This function answers how the shape will change after interacting
#with a ball that has flown in a given direction. Due to the fact
#that I did not find a way to easily and clearly arrange the figures
#in the tileset, I arranged them as logically as I could, and then
#there was a choice: to load individually the parameters of each
#figure from a table file or to register them by branching in the
#code. The choice fell on the second option. It will be possible to
#convert to the first one only if the picture is also stored in the
#table
func change_cell(cell: Vector2, dir: int) -> Vector2:
	if dir < 0 or dir >= 4: dir = wrapi(dir, 0, 4)#cutout
	
	var shift = int(cell.x) % 4 #shift the direction of the shape clockwise
	var change: Vector2 #most often it is enough to specify only one change
	var change_matrix: PoolVector2Array #but actually a whole matrix is needed,
	#since the change depends on the direction
	
	var template: PoolIntArray #The template shows which directions change the shape
	#we have it int, not boolean, because it is clearer
	var template_triangle = f.array4x(1, 1, 0, 0)
	var template_flag = f.array4x(1, 0, 0, 0)
	var template_second = f.array4x(1, 0, 0, 1)
	var template_special = f.array4x(1, 1, 0, 1)
	
	#I had to cram the sounds into a ready-made system.
	var sound_1: String
	var sound_2: String
	
	#Choosing a color change. For complex shapes, select the matrix immediately.
	#Here we also set the type of sound, if any.
	if cell.x < 8:
		match int(cell.y):
			0: change = Vector2(0, 0)
			1:
				sound_1 = "deactivate"
				change = Vector2(0, 6)
			2:
				sound_1 = "deactivate"
				change = Vector2(0, -1)
			3:
				sound_1 = "deactivate"
				change = Vector2(0, -1)
			4:
				sound_1 = "activate"
				change = Vector2(0, -4)
			5:
				sound_1 = "activate"
				change = Vector2(0, -1)
			6:
				sound_1 = "activate"
				change = Vector2(0, -1)
			7: change = Vector2(0, 0)
	elif cell.x >= 8 and cell.x < 20:
		match int(cell.y):
			0:
				sound_2 = "activate"
				change = Vector2(12, 0)
			1: change = Vector2(0, 0)
			2:
				change = Vector2(0, 0)
				sound_1 = "deactivate"
				sound_2 = "activate"
				if cell.x < 12:
					change_matrix = f.array8x(0, 3, 12, 4, 0, 0, 12, 0)
				elif cell.x >= 12 and cell.x < 16:
					change_matrix = f.array8x(0, 3, 12, 4, 0, 0, 0, 0)
				else:
					change_matrix = f.array8x(0, 3, 0, 0, 0, 0, 12, 0)
			3:
				sound_1 = "deactivate"
				change = Vector2(12, 4)
			4:
				sound_1 = "activate"
				change = Vector2(12, -4)
			5: change = Vector2(0, 0)
			6: 
				change = Vector2(0, 0)
				sound_1 = "activate"
				sound_2 = "deactivate"
				if cell.x < 12:
					change_matrix = f.array8x(0, -5, 12, -5, 0, 0, 12, -1)
				elif cell.x >= 12 and cell.x < 16:
					change_matrix = f.array8x(0, -5, 12, -5, 0, 0, 0, 0)
				else:
					change_matrix = f.array8x(0, -5, 0, 0, 0, 0, 12, -1)
			7:
				sound_2 = "deactivate"
				change = Vector2(12, 0)
	elif cell.x >= 20 and cell.x < 32:
		match int(cell.y):
			0: change = Vector2(0, 0)
			1:
				sound_2 = "deactivate"
				change = Vector2(-12, 0)
			2:
				sound_1 = "deactivate"
				change = Vector2(-12, 3)
			3: 
				sound_1 = "deactivate"
				sound_2 = "deactivate"
				change = Vector2(0, 0)
				if cell.x < 24:
					change_matrix = f.array8x(0, 4, -12, 4, 0, 0, -12, 0)
				elif cell.x >= 24 and cell.x < 28:
					change_matrix = f.array8x(0, 4, -12, 4, 0, 0, 0, 0)
				else:
					change_matrix = f.array8x(0, 4, 0, 0, 0, 0, -12, 0)
			4: 
				sound_1 = "activate"
				sound_2 = "activate"
				change = Vector2(0, 0)
				if cell.x < 24:
					change_matrix = f.array8x(0, -4, -12, -4, 0, 0, -12, 0)
				elif cell.x >= 24 and cell.x < 28:
					change_matrix = f.array8x(0, -4, -12, -4, 0, 0, 0, 0)
				else:
					change_matrix = f.array8x(0, -4, 0, 0, 0, 0, -12, 0)
			5:
				sound_1 = "activate"
				change = Vector2(-12, -4)
			6:
				sound_2 = "activate"
				change = Vector2(-12, -1)
			7:
				sound_1 = ""
				sound_2 = ""
				change = Vector2(0, 0)
	elif cell.x >= 32 and cell.x < 40:
		match int(cell.y):
			0:
				sound_1 = "deactivate"
				change = Vector2(0, 1)
			1:
				sound_1 = "activate"
				change = Vector2(0, -1)
			2: #Swiveling triangles are an exception
				s1.stream = r.turn_right_sound
				s1.pitch_scale = f.random(0.95, 1.05)
				s2.stream = null
				if cell.x < 36:
					match shift:
						0: if dir == 0 or dir == 1:
							s1.play()
							return cell + Vector2(3, 0)
						1: if dir == 3 or dir == 0:
							s1.play()
							return cell + Vector2(-1, 0)
						2: if dir == 2 or dir == 3:
							s1.play()
							return cell + Vector2(-1, 0)
						3: if dir == 1 or dir == 2:
							s1.play()
							return cell + Vector2(-1, 0)
				else:
					match shift:
						0: if dir == 0:
							s1.play()
							return cell + Vector2(3, 0)
						1: if dir == 3:
							s1.play()
							return cell + Vector2(-1, 0)
						2: if dir == 2:
							s1.play()
							return cell + Vector2(-1, 0)
						3: if dir == 1:
							s1.play()
							return cell + Vector2(-1, 0)
				s1.stream = null
				s2.stream = null
				return cell
			3:
				s1.stream = r.turn_left_sound
				s1.pitch_scale = f.random(0.95, 1.05)
				s2.stream = null
				#s1.play()
				if cell.x < 36:
					match shift:
						0: if dir == 0 or dir == 1:
							s1.play()
							return cell + Vector2(1, 0)
						1: if dir == 3 or dir == 0:
							s1.play()
							return cell + Vector2(1, 0)
						2: if dir == 2 or dir == 3:
							s1.play()
							return cell + Vector2(1, 0)
						3: if dir == 1 or dir == 2:
							s1.play()
							return cell + Vector2(-3, 0)
				else:
					match shift:
						0: if dir == 0:
							s1.play()
							return cell + Vector2(1, 0)
						1: if dir == 3:
							s1.play()
							return cell + Vector2(1, 0)
						2: if dir == 2:
							s1.play()
							return cell + Vector2(1, 0)
						3: if dir == 1:
							s1.play()
							return cell + Vector2(-3, 0)
				
				s1.stream = null
				s2.stream = null
				return cell
			4, 5, 6, 7:
				s1.stream = r.deactivate_sound
				s1.pitch_scale = f.random(0.95, 1.05)
				s1.play()
				if shift < 3: return cell + Vector2(1, 0)
				else: return cell + Vector2(-3, 0)
				
	else: return cell
	
	#We choose a template according to which we will later erase values from the matrix
	if cell.x < 8:
		if cell.y >= 1 and cell.y < 7:
			if cell.x < 4: template = template_triangle
			else: template = template_flag
		else: return cell
	elif cell.x >= 8 and cell.x < 20:
		if int(cell.y) % 4 == 1: return cell
		elif int(cell.y) % 4 == 2: template = template_special
		else:
			if cell.y < 1 or cell.y >= 7:
				if cell.x >= 12 and cell.x < 16: template = template_flag
				else: template = template_second
			else:
				if cell.x >= 16: template = template_flag
				else: template = template_triangle
	elif cell.x >= 20 and cell.x < 32:
		if cell.y >= 1 or cell.y < 7:
			if cell.y >= 3 and cell.y < 5: template = template_special
			elif cell.y < 2 or cell.y >= 6:
				if cell.x < 24 or cell.x >= 28: template = template_second
				else: template = template_flag
			else:
				if cell.x >= 28: template = template_flag
				else: template = template_triangle
		else: return cell
	elif cell.x >= 32:
		if int(cell.y == 0) or int(cell.y == 1):
			if cell.x < 36: template = template_triangle
			else: template = template_flag
		elif int(cell.y == 2) or int(cell.y == 3):
			template = template_special
		else: return cell

	#check that the matrix is not special, according to a special template
	#The special matrices are already filled in. But we fill in the usual ones here.
	if template != template_special:
		change_matrix = f.array4vect(change, change, change, change)
	
	#and apply the template
	for i in range(4):
		change_matrix[i] *= template[i]
	change_matrix = f.shift_array(change_matrix, shift)
	
	#now we fill in the sound matrices. They are easier to distribute.
	var sound_matrix = []
# warning-ignore:narrowing_conversion
	var col: int = floor(cell.x / 4) * 4
	match col:
		0: sound_matrix = f.shift_array(f.array4x(1, 1, 0, 0), shift)
		4: sound_matrix = f.shift_array(f.array4x(1, 0, 0, 0), shift)
		8: sound_matrix = f.shift_array(f.array4x(2, 1, 0, 3), shift)
		12: sound_matrix = f.shift_array(f.array4x(2, 1, 0, 0), shift)
		16: sound_matrix = f.shift_array(f.array4x(2, 0, 0, 3), shift)
		20: sound_matrix = f.shift_array(f.array4x(2, 1, 0, 3), shift)
		24: sound_matrix = f.shift_array(f.array4x(2, 1, 0, 0), shift)
		28: sound_matrix = f.shift_array(f.array4x(2, 0, 0, 3), shift)
		32: sound_matrix = f.shift_array(f.array4x(1, 1, 0, 0), shift)
		36: sound_matrix = f.shift_array(f.array4x(1, 0, 0, 0), shift)
		
	#now we load the necessary sounds, but only if they should sound.
	#If not, we unload, despite the protests.
	if sound_1 == "activate":
		s1.stream = r.activate_sound
	elif sound_1 == "deactivate":
		s1.stream = r.deactivate_sound
	else:
		if sound_matrix[dir] == 1 or sound_matrix[dir] == 2:
			s1.stream = null
	if sound_2 == "activate":
		s2.stream = r.activate_sound
	elif sound_2 == "deactivate":
		s2.stream = r.deactivate_sound
	else:
		if sound_matrix[dir] == 3 or sound_matrix[dir] == 2:
			s2.stream = null
	
	#random pitch will give liveliness
	s1.pitch_scale = f.random(0.95, 1.05)
	s2.pitch_scale = f.random(0.95, 1.05)

	#and reproduce the set of sounds indicated in the matrix in this direction
	match sound_matrix[dir]:
		1: s1.play()
		2:
			s1.play()
			s2.play()
		3: s2.play()
	
	#yes, now we can return the result.
	#We changed the figure there after the collision
	return cell + change_matrix[dir]
	#TODO: separate sound from shape change


#This will help to arrange figures somehow
func palette_to_tilemap(desc: CellDesc) -> Vector2:
# warning-ignore:unassigned_variable
	var cell: Vector2
	var x = int(desc.xy.x)
	var y = int(desc.xy.y)
	
	#var shift: int
	if desc.is_doubled:
		if desc.is_flag:
			if desc.is_reversed:
				#doubled, flag, reversed
				match y:
					0:
						match x:
							0:
								cell.x = 28
								cell.y = 0
							1:
								cell.x = 28
								cell.y = 2
							2:
								cell.x = 16
								cell.y = 4
							3:
								cell.x = 16
								cell.y = 5
					1:
						match x:
							0:
								cell.x = 28
								cell.y = 1
							1:
								cell.x = 28
								cell.y = 3
							2:
								cell.x = 16
								cell.y = 6
							3:
								cell.x = 16
								cell.y = 7
					2:
						match x:
							0:
								cell.x = 16
								cell.y = 0
							1:
								cell.x = 16
								cell.y = 2
							2:
								cell.x = 28
								cell.y = 4
							3:
								cell.x = 28
								cell.y = 6
					3:
						match x:
							0:
								cell.x = 16
								cell.y = 1
							1:
								cell.x = 16
								cell.y = 3
							2:
								cell.x = 28
								cell.y = 5
							3:
								cell.x = 28
								cell.y = 7
			else:
				#doubled, flag, not reversed
				match y:
					0:
						match x:
							0:
								cell.x = 24
								cell.y = 0
							1:
								cell.x = 24
								cell.y = 1
							2:
								cell.x = 12
								cell.y = 0
							3:
								cell.x = 12
								cell.y = 1
					1:
						match x:
							0:
								cell.x = 24
								cell.y = 2
							1:
								cell.x = 24
								cell.y = 3
							2:
								cell.x = 12
								cell.y = 2
							3:
								cell.x = 12
								cell.y = 3
					2:
						match x:
							0:
								cell.x = 12
								cell.y = 4
							1:
								cell.x = 12
								cell.y = 6
							2:
								cell.x = 24
								cell.y = 4
							3:
								cell.x = 24
								cell.y = 5
					3:
						match x:
							0:
								cell.x = 12
								cell.y = 5
							1:
								cell.x = 12
								cell.y = 7
							2:
								cell.x = 24
								cell.y = 6
							3:
								cell.x = 24
								cell.y = 7
		else: 
			if desc.is_reversed:
				#doubled, not flag, reversed
				match y:
					0:
						match x:
							0:
								cell.x = 20
								cell.y = 0
							1:
								cell.x = 20
								cell.y = 2
							2:
								cell.x = 8
								cell.y = 4
							3:
								cell.x = 8
								cell.y = 5
					1:
						match x:
							0:
								cell.x = 20
								cell.y = 1
							1:
								cell.x = 20
								cell.y = 3
							2:
								cell.x = 8
								cell.y = 6
							3:
								cell.x = 8
								cell.y = 7
					2:
						match x:
							0:
								cell.x = 8
								cell.y = 0
							1:
								cell.x = 8
								cell.y = 2
							2:
								cell.x = 20
								cell.y = 4
							3:
								cell.x = 20
								cell.y = 6
					3:
						match x:
							0:
								cell.x = 8
								cell.y = 1
							1:
								cell.x = 8
								cell.y = 3
							2:
								cell.x = 20
								cell.y = 5
							3:
								cell.x = 20
								cell.y = 7
			else:
				#doubled, not flag, not reversed
				match y:
					0:
						match x:
							0:
								cell.x = 20
								cell.y = 0
							1:
								cell.x = 20
								cell.y = 1
							2:
								cell.x = 8
								cell.y = 0
							3:
								cell.x = 8
								cell.y = 1
					1:
						match x:
							0:
								cell.x = 20
								cell.y = 2
							1:
								cell.x = 20
								cell.y = 3
							2:
								cell.x = 8
								cell.y = 2
							3:
								cell.x = 8
								cell.y = 3
					2:
						match x:
							0:
								cell.x = 8
								cell.y = 4
							1:
								cell.x = 8
								cell.y = 6
							2:
								cell.x = 20
								cell.y = 4
							3:
								cell.x = 20
								cell.y = 5
					3:
						match x:
							0:
								cell.x = 8
								cell.y = 5
							1:
								cell.x = 8
								cell.y = 7
							2:
								cell.x = 20
								cell.y = 6
							3:
								cell.x = 20
								cell.y = 7
	else:
		if desc.is_reversed:
		#reversed and not doubled: misc decorative figures
			if desc.is_flag:
				cell.x = (x + desc.rotation) % 4 + 36 
				cell.y = y + 4
			else:
				cell.x = (x + desc.rotation) % 4 + 32
				cell.y = y + 4
			return cell
		else:
		#not doubled: regular figures only
			match y:
				0:
					#blue and variants of green
					if x == 0:
						cell.y = 7
					else:
						cell.y = x
					cell.x = 0
				1:
					#red and variants of red
					if x == 0:
						cell.y = 0
					else:
						cell.y = x + 3
					cell.x = 0
				2:
					#periodic figures
					cell.x = 32
					cell.y = x
				3:
					#just regular blue triangles/flags rotated some ways
					cell.y = 0
					cell.x = (int(x) + desc.rotation) % 4
					if desc.is_flag: cell.x = cell.x + 4
					return cell
			if desc.is_flag: cell.x = cell.x + 4
	
	cell.x = cell.x + desc.rotation % 4
	return cell

func tilemap_to_palette(cell: Vector2):
	var desc = CellDesc.new()
	desc.rotation = int(cell.x) % 4
	var x = int(floor(cell.x / 4))
	var y = int(cell.y)
	
	match x:
		0, 1:
			desc.is_doubled = false
			desc.is_reversed = false
			if x == 1: desc.is_flag = true
			match y:
				#regular triangles
				0:
					desc.xy.y = 1
					desc.xy.x = 0
				1, 2, 3:
					desc.xy.y = 0
					desc.xy.x = y
				4, 5, 6:
					desc.xy.y = 1
					desc.xy.x = y - 3
				7:
					desc.xy.y = 0
					desc.xy.x = 0
		2, 3:
			desc.is_doubled = true
			desc.is_reversed = false
			desc.is_flag = false
			
			if x == 3: desc.is_flag = true
				
			match y:
				0, 1:
					desc.xy.y = 0
					desc.xy.x = y+ 2
				2, 3:
					desc.xy.y = 1
					desc.xy.x = y
				4, 5:
					desc.xy.x = 0
					desc.xy.y = y - 2
				6, 7:
					desc.xy.x = 1
					desc.xy.y = y - 4
		4:
			desc.is_doubled = true
			desc.is_reversed = true
			desc.is_flag = true
			match y:
				0, 1:
					desc.xy.x = 0
					desc.xy.y = y + 2
				2, 3:
					desc.xy.x = 1
					desc.xy.y = y
				4, 5:
					desc.xy.y = 0
					desc.xy.x = y - 2
				6, 7:
					desc.xy.y = 1
					desc.xy.x = y - 4
		5, 6:
			desc.is_doubled = true
			desc.is_reversed = false
			desc.is_flag = false
			if x == 6: desc.is_flag = true
			match y:
				0, 1:
					desc.xy.y = 0
					desc.xy.x = y
				2, 3:
					desc.xy.y = 1
					desc.xy.x = y - 2
				4, 5:
					desc.xy.y = 2
					desc.xy.x = y - 2
				6, 7:
					desc.xy.y = 3
					desc.xy.x = y - 4
		7:
			desc.is_doubled = true
			desc.is_reversed = true
			desc.is_flag = true
			match y:
				0, 1:
					desc.xy.x = 0
					desc.xy.y = y
				2, 3:
					desc.xy.x = 1
					desc.xy.y = y - 2
				4, 5:
					desc.xy.x = 2
					desc.xy.y = y - 2
				6, 7:
					desc.xy.x = 3
					desc.xy.y = y - 4
			
		8, 9:
			desc.is_doubled = false
			if x==9: desc.is_flag = true
			match y:
				0, 1, 2, 3:
					desc.xy.x = y
					desc.xy.y = 2
					desc.is_reversed = false
				4, 5, 6, 7:
					#misc figures
					desc.is_reversed = true
					desc.xy.x = cell.x - desc.rotation - 32
					desc.xy.y = y - 4
	
	return desc



#this function tells what shape will turn out after rotation.
#useful for editing.
func rotate_cell(cell: CellDesc, right: bool = true) -> CellDesc:
	if right:
		cell.rotation = (cell.rotation + 1) % 4
	else:
		cell.rotation = (cell.rotation + 3) % 4
	return cell

func rotate_cell_tilemap(cell: Vector2, right: bool = true) -> Vector2:
	var cell_desc = tilemap_to_palette(cell)
	var new_desc = rotate_cell(cell_desc, right)
	return palette_to_tilemap(new_desc)


#this function tells which shape will be the next or previous type.
#Useful for editing.
func shift_cell(cell: CellDesc, forward: bool = true) -> CellDesc:
	if forward:
		if int(cell.xy.x) == 3:
			cell.xy.y = (int(cell.xy.y) + 1) % 4
		cell.xy.x = (int(cell.xy.x) + 1) % 4
	else:
		if int(cell.xy.x) == 0:
			cell.xy.y = (int(cell.xy.y) + 3) % 4
		cell.xy.x = (int(cell.xy.x) + 3) % 4
	
	return cell


func shift_cell_tilemap(cell: Vector2, forward: bool = true) -> Vector2:
	var cell_desc = tilemap_to_palette(cell)
	var new_desc = shift_cell(cell_desc, forward)
	return palette_to_tilemap(new_desc)
