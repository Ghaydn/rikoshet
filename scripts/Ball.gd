extends KinematicBody2D
#Our ball that moves.
#It is kinematic for extensibility reasons

export(float, 10, 10000) var speed
export(int, 0, 3) var direction setget set_dir
var past_direction: int
onready var pole = get_parent()
var velocity
var current_cell: Vector2 = Vector2(-1, -1)
var current_cell_center: Vector2
var past_position: Vector2
var cell_visited: bool


onready var triangle_sound   = $sounds/triangle
onready var flag_sound       = $sounds/flag
onready var pass_sound       = $sounds/pass

func _ready():
	if g.pole.count_balls() == 1:
		g.pole.make_backup()
	#g.cam.reparent()


#if the ball disappears, it must first get rid of the camera
func disappear():
	var splash = r.death_splash.instance()
	g.pole.add_child(splash)
	splash.global_position = global_position
	
	queue_free()
	g.call_deferred("reparent_cam")
	if g.pole.count_balls() == 0 and g.pole.backup_enabled: g.pole.restore_from_backup()

func set_color(col: Color):
	$image.modulate = col
	$tail.modulate = col

func set_dir(dir: int):
	dir = wrapi(dir, 0, 4) #for the case if its negative
	direction = dir

#The ball has a _physics_process! The camera also has it and no one else has it.
func _physics_process(delta):
	#The speed of movement is constant, we choose only the direction
	match direction:
		0: velocity = Vector2(speed, 0)
		1: velocity = Vector2(0, speed)
		2: velocity = Vector2(-speed, 0)
		3: velocity = Vector2(0, -speed)
	
	
	var cell_coord
# warning-ignore:unused_variable
	var cell
	
	#we get our coordinates and the type of cell under them
	if pole.has_method("get_cell_coord"):
		cell_coord = pole.get_cell_coord(global_position)
	if pole.has_method("get_cell_type"):
		cell = pole.get_cell_type(cell_coord)
	
	if cell_coord != current_cell:
		cell_visited = false
		current_cell = cell_coord
		if pole.has_method("to_center"):
			current_cell_center = pole.to_center(current_cell)
	
# warning-ignore:return_value_discarded
	move_and_collide(velocity * delta)
	
	if not pole.get_rect().has_point(pole.get_cell_coord(global_position)):
		g.answer("ball " + self.to_string() + " out of bounds, disappear. Position: " + String(position))
		#var splash = r.death_splash.instance()
		#splash.position = position
		#g.pole.add_child(splash)
		disappear()
	
	if past_position.distance_to(current_cell_center) < global_position.distance_to(current_cell_center) and not cell_visited:
		if pole.has_method("has_something"):
			if pole.has_something(current_cell):
				past_direction = direction
				#at first it was just a change of direction,
				#but later sounds were added.
				direction = pole.hit_cell(cell_coord, direction)
				match int(abs(direction - past_direction)):
					0:
						pass_sound.pitch_scale = f.random(0.9, 1.1)
						pass_sound.play()
					2:
						$hit.restart()
						$hit.emitting = true
						flag_sound.pitch_scale = f.random(0.9, 1.1)
						flag_sound.play()
					_:
						$hit.restart()
						$hit.emitting = true
						triangle_sound.pitch_scale = f.random(0.9, 1.1)
						triangle_sound.play()
					
				
				global_position = current_cell_center
				cell_visited = true
	past_position = global_position
