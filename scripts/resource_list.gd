extends Node

var ball = preload("res://scenes/ball.scn")
var eater = preload("res://scenes/ball_eater.scn")
var emitter = preload("res://scenes/ball_emitter.scn")
var death_splash = preload("res://scenes/death_splash.scn")
var ball_image = preload("res://images/ball.png")
var cam_image = preload("res://images/cam.png")
var cam_ball_image = preload("res://images/cam_ball.png")
var eater_image = preload("res://images/ball_eater.png")
var emitter_image = preload("res://images/ball_emitter.png")
var eraser_image = preload("res://images/eraser.png")
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

func _ready():
	if ball == null: print("ERROR: cannot preload ball.scn")
	if eater == null: print("ERROR: cannot preload ball_eater.scn")
	if emitter == null: print("ERROR: cannot preload ball_emitter.scn")
	if death_splash == null: print("ERROR: cannot preload death_splash.scn")
	if ball_image == null: print("ERROR: cannot preload ball.png")
	if cam_ball_image == null: print("ERROR: cannot preload cam_ball.png")
	if eater_image == null: print("ERROR: cannot preload ball_eater.png")
	if emitter_image == null: print("ERROR: cannot preload ball_emitter.png")
	if eraser_image == null: print("ERROR: cannot preload eraser.png")
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
	
	var dir = Directory.new()
	if not dir.file_exists("user://demo.tres") and dir.file_exists("res://maps/demo.tres"):
		dir.copy("res://maps/demo.tres", "user://demo.tres")

	if not dir.file_exists("user://loop.tres") and dir.file_exists("res://maps/loop.tres"):
		dir.copy("res://maps/loop.tres", "user://loop.tres")
		
	if not dir.file_exists("user://demo.png") and dir.file_exists("res://maps/demo.png"):
		dir.copy("res://maps/demo.png", "user://demo.png")

	if not dir.file_exists("user://loop.png") and dir.file_exists("res://maps/loop.png"):
		dir.copy("res://maps/loop.png", "user://loop.png")
