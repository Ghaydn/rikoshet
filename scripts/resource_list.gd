extends Node

var ball = preload("res://scenes/ball.scn")
var eater = preload("res://scenes/ball_eater.scn")
var emitter = preload("res://scenes/ball_emitter.scn")
var text = preload("res://scenes/text.scn")
var death_splash = preload("res://scenes/death_splash.scn")
var cam = preload("res://scenes/cam.scn")

var ball_image = preload("res://images/ball.png")
var cam_image = preload("res://images/cam.png")
var cam_ball_image = preload("res://images/cam_ball.png")
var eater_image = preload("res://images/ball_eater.png")
var emitter_image = preload("res://images/ball_emitter.png")
var eraser_image = preload("res://images/eraser.png")
var pipette_image = preload("res://images/pipette.png")
var text_image = preload("res://images/letter.png")
var circle_image = preload("res://images/circle.png")
var mute_image = preload("res://images/mute.png")
var pause_image = preload("res://images/pause.png")
var play_image = preload("res://images/play.png")
var speaker_image = preload("res://images/speaker.png")
var tilemap_image = preload("res://images/tilemap.png")
var triangle_image = preload("res://images/triangle.png")

var activate_sound = preload("res://sounds/activate.wav")
var deactivate_sound = preload("res://sounds/deactivate.wav")
var turn_left_sound = preload("res://sounds/turn_left.wav")
var turn_right_sound = preload("res://sounds/turn_right.wav")

var drummed_music = preload("res://music/drummed.ogg")
var pads_music = preload("res://music/pads.ogg")
var sine_fast_music = preload("res://music/sine_fast.ogg")
var sine_slow_music = preload("res://music/sine_slow.ogg")

func _ready():
	if ball == null: print("ERROR: cannot preload ball.scn")
	if eater == null: print("ERROR: cannot preload ball_eater.scn")
	if emitter == null: print("ERROR: cannot preload ball_emitter.scn")
	if text == null: print("ERROR: cannot preload text.scn")
	if death_splash == null: print("ERROR: cannot preload death_splash.scn")
	if cam == null: print("ERROR: cannot preload cam.scn")
	
	if ball_image == null: print("ERROR: cannot preload ball.png")
	if cam_ball_image == null: print("ERROR: cannot preload cam_ball.png")
	if eater_image == null: print("ERROR: cannot preload ball_eater.png")
	if emitter_image == null: print("ERROR: cannot preload ball_emitter.png")
	if eraser_image == null: print("ERROR: cannot preload eraser.png")
	if pipette_image == null: print("ERROR: cannot preload pipette.png")
	if text_image == null: print("ERROR: cannot preload letter.png")
	if circle_image == null: print("ERROR: cannot preload circle.png")
	if mute_image == null: print("ERROR: cannot preload mute.png")
	if pause_image == null: print("ERROR: cannot preload pause.png")
	if play_image == null: print("ERROR: cannot preload play.png")
	if speaker_image == null: print("ERROR: cannot preload speaker.png")
	if tilemap_image == null: print("ERROR: cannot preload tilemap.png")
	if triangle_image == null: print("ERROR: cannot preload triangle.png")
	
	if activate_sound == null: print("ERROR: cannot preload activate.wav")
	if deactivate_sound == null: print("ERROR: cannot preload deactivate.wav")
	if turn_left_sound == null: print("ERROR: cannot preload turn_left.wav")
	if turn_right_sound == null: print("ERROR: cannot preload turn_right.wav")
	
	if drummed_music == null: print("ERROR: cannot preload drummed.ogg")
	if pads_music == null: print("ERROR: cannot preload pads.ogg")
	if sine_fast_music == null: print("ERROR: cannot preload sine_fast.ogg")
	if sine_slow_music == null: print("ERROR: cannot preload sine_slow.ogg")
	
	
	var dir = Directory.new()
	if not dir.file_exists("user://demo1.tres") and dir.file_exists("res://maps/demo1.tres"):
		dir.copy("res://maps/demo1.tres", "user://demo1.tres")

	var png = load("res://maps/demo1.png")
	if not dir.file_exists("user://demo1.png") and png != null:
		png.get_data().save_png("user://demo1.png")

	if not dir.file_exists("user://demo2.tres") and dir.file_exists("res://maps/demo2.tres"):
		dir.copy("res://maps/demo2.tres", "user://demo2.tres")

	png = load("res://maps/demo2.png")
	if not dir.file_exists("user://demo2.png") and png != null:
		png.get_data().save_png("user://demo2.png")

	if not dir.file_exists("user://loop1.tres") and dir.file_exists("res://maps/loop1.tres"):
		dir.copy("res://maps/loop1.tres", "user://loop1.tres")

	png = load("res://maps/loop1.png")
	if not dir.file_exists("user://loop1.png") and png != null:
		png.get_data().save_png("user://loop1.png")

	if not dir.file_exists("user://loop2.tres") and dir.file_exists("res://maps/loop2.tres"):
		dir.copy("res://maps/loop2.tres", "user://loop2.tres")

	png = load("res://maps/loop2.png")
	if not dir.file_exists("user://loop2.png") and png != null:
		png.get_data().save_png("user://loop2.png")

	if not dir.file_exists("user://chaotic.tres") and dir.file_exists("res://maps/chaotic.tres"):
		dir.copy("res://maps/chaotic.tres", "user://chaotic.tres")

	png = load("res://maps/chaotic.png")
	if not dir.file_exists("user://chaotic.png") and png != null:
		png.get_data().save_png("user://chaotic.png")

	if not dir.file_exists("user://tutorial.tres") and dir.file_exists("res://maps/tutorial.tres"):
		dir.copy("res://maps/tutorial.tres", "user://tutorial.tres")

	png = load("res://maps/tutorial.png")
	if not dir.file_exists("user://tutorial.png") and png != null:
		png.get_data().save_png("user://tutorial.png")
