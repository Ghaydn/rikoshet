extends Camera2D 

#Camera script

var velocity: Vector2
var ext_velocity: Vector2
var target_zoom: float = 1.25
onready var pole = get_parent()
var parented: bool
var parent: Node


const SPEED = g.MIN_SPEED * 2
const ZOOM_MAX = 5.0
const ZOOM_MIN = 0.5
const ZOOM_SPEED = 10.0
const ZOOM_STEP = 0.25

func _ready():
	g.cam = self
	update_properties()

func _input(event):
	if g.editor.edit_text: return
	
	if Input.is_action_pressed("ctrl"):
		if Input.is_action_just_pressed("scroll_up"):
			if get_parent() == pole:
				position = (position + get_global_mouse_position()) / 2
			zoom_in()
		elif Input.is_action_just_pressed("scroll_down"):
			if get_parent() == pole:
				position = (position + get_global_mouse_position()) / 2
			zoom_out()
	
	if Input.is_action_just_pressed("reparent_cam"):
		g.reparent_cam(not g.cam_parented)
	
	
	if Input.is_action_just_pressed("mute"):
		g.toggle_mute_sounds()
	
	if Input.is_action_just_pressed("pause"):
		g.pause()
	
	if event is InputEventMagnifyGesture:
		var nzoom = clamp(zoom.x * event.factor, ZOOM_MIN, ZOOM_MAX)
		zoom = Vector2(nzoom, nzoom)
	
	if event is InputEventMouseMotion:
		if event.button_mask == BUTTON_MASK_MIDDLE:
			move_cam(event.relative * zoom)
	
	if event is InputEventScreenDrag:
		move_cam(event.relative * zoom)
	
	if event.is_action("move_down") or event.is_action("move_left") \
	or event.is_action("move_right") or event.is_action("move_up"):
		#TODO: fix a bug. This is a stub for that.
		#0. Remove "update_properties()"
		#1. Launch some balls
		#2. Load a level
		#3. Try to move a camera. It has properties as an attached one.
		update_properties()

func move_cam(distance: Vector2):
	if get_parent() == pole:
		position -= distance


func cam_up_pressed():
	ext_velocity = Vector2.UP

func cam_up_released():
	ext_velocity *= Vector2(1, 0)

func cam_down_pressed():
	ext_velocity = Vector2.DOWN

func cam_down_released():
	ext_velocity *= Vector2(1, 0)

func cam_left_pressed():
	ext_velocity = Vector2.LEFT

func cam_left_released():
	ext_velocity *= Vector2(0, 1)

func cam_right_pressed():
	ext_velocity = Vector2.RIGHT

func cam_right_released():
	ext_velocity *= Vector2(0, 1)


func zoom_in():
	target_zoom -= ZOOM_STEP
	target_zoom = clamp(target_zoom, ZOOM_MIN, ZOOM_MAX)


func zoom_out():
	target_zoom += ZOOM_STEP
	target_zoom = clamp(target_zoom, ZOOM_MIN, ZOOM_MAX)

#This function attaches the camera to the ball. Or detaches back.
func reparent(new_parent):
	if not is_instance_valid(new_parent) : return
	if parent == new_parent: return
	parent = new_parent
	update_properties()

func find_new_parent():
	if parented:
		if pole.get_child_count() > 4:
			for child in pole.get_children():
				if child.has_method("disappear"):
					reparent(child)
					return
	reparent(pole)


func update_properties():
	if is_instance_valid(parent) and parent.has_method("disappear"):
		drag_margin_h_enabled = true
		drag_margin_v_enabled = true
		position = Vector2.ZERO
	else:
		drag_margin_h_enabled = false
		drag_margin_v_enabled = false


#The camera is one of two nodes with a _physics_process.
#It is needed here for movement and for smooth zoom.
func _physics_process(delta):
	if g.saveload_dialogs.is_visible() or g.help_panel.visible: return
	
	if parented:
		if parent == pole:
			move_on_pole(delta)
			find_new_parent()
		else:
			if is_instance_valid(parent):
				position = parent.global_position
			else:
				find_new_parent()
	else:
		if parent == pole:
			move_on_pole(delta)
		else:
			find_new_parent()
	
	if zoom != Vector2(target_zoom, target_zoom):
		zoom = lerp(zoom, Vector2(target_zoom, target_zoom), ZOOM_SPEED * delta)

func move_on_pole(delta):
	velocity = ext_velocity
	if not g.editor.edit_text \
	and not Input.is_action_pressed("shift") \
	and not Input.is_action_pressed("ctrl") \
	and velocity == Vector2.ZERO:
		velocity = Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), \
											 Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	velocity *= SPEED * zoom
	position += velocity * delta
	velocity = Vector2.ZERO
	
