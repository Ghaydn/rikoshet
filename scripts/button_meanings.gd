extends Node

#A script just to keep all UI buttons on one place
#All calls must be as simple as possible

func button_eater():
	g.editor.button_eater()
	g.interface.hide_mixer()

func button_emitter():
	g.editor.button_emitter()
	g.interface.hide_mixer()

func button_eraser():
	g.editor.button_erase()
	g.interface.hide_mixer()

func button_pipette():
	g.editor.button_pipette()
	g.interface.hide_mixer()

func button_text():
	g.editor.button_text()
	g.interface.hide_mixer()


func button_rotate_right():
	g.interface.button_rotate_right()
	g.interface.hide_mixer()

func button_rotate_left():
	g.interface.button_rotate_left()
	g.interface.hide_mixer()

func button_go():
	g.editor.button_go()
	g.interface.hide_palette()

func button_killballs():
	g.editor.button_killballs()
	g.interface.hide_mixer()

func button_clear():
	g.editor.button_clear()
	g.interface.hide_mixer()

func button_save():
	g.saveload_dialogs.show_save()
	g.interface.hide_mixer()

func button_load():
	g.saveload_dialogs.show_load()
	g.interface.hide_mixer()


func button_mute():
	g.toggle_mute_sounds()

func button_mute_music():
	g.music.toggle_mute()


func button_pause():
	g.pause()
	g.interface.hide_mixer()

func button_zoom_in():
	g.cam.zoom_in()
	g.interface.hide_mixer()

func button_zoom_out():
	g.cam.zoom_out()
	g.interface.hide_mixer()

func button_pin_cam(value: bool):
	g.cam.parented = value
	g.save_settings()
	g.interface.hide_mixer()

func button_exit():
	g.quit()

func cam_up_pressed():
	g.cam.cam_up_pressed()
	g.interface.hide_mixer()

func cam_up_released():
	g.cam.cam_up_released()
	g.interface.hide_mixer()

func cam_down_pressed():
	g.cam.cam_down_pressed()
	g.interface.hide_mixer()

func cam_down_released():
	g.cam.cam_down_released()
	g.interface.hide_mixer()

func cam_left_pressed():
	g.cam.cam_left_pressed()
	g.interface.hide_mixer()

func cam_left_released():
	g.cam.cam_left_released()
	g.interface.hide_mixer()

func cam_right_pressed():
	g.cam.cam_right_pressed()
	g.interface.hide_mixer()

func cam_right_released():
	g.cam.cam_right_released()
	g.interface.hide_mixer()

func palette_button(pos: Vector2):
	g.editor.show_painter()
	g.editor.button_select_fig(pos)
	g.interface.hide_mixer()

func button_toggle_flag(value: bool):
	g.interface.palette_flag = value
	g.interface.update_palette()
	g.interface.hide_mixer()
	#g.interface.button_flag.modulate = Color(0.8, 0.8, 0.8) if value else Color(1.0, 1.0, 1.0)

func button_toggle_double(value: bool):
	g.interface.palette_doubled = value
	g.interface.update_palette()
	g.interface.hide_mixer()
	#g.interface.button_double.modulate = Color(0.8, 0.8, 0.8) if value else Color(1.0, 1.0, 1.0)

func button_toggle_reverse(value: bool):
	g.interface.palette_reversed = value
	g.interface.update_palette()
	g.interface.hide_mixer()
	#g.interface.button_reversed.modulate = Color(0.8, 0.8, 0.8) if value else Color(1.0, 1.0, 1.0)

func _on_reset_palette_pressed() -> void:
	g.interface.palette_doubled = false
	g.interface.palette_reversed = false
	g.interface.palette_flag = false
	g.interface.update_palette()
	g.interface.hide_mixer()


func _on_fullscreen_toggled(button_pressed: bool) -> void:
	g.set_fullscreen(button_pressed)
	

func button_show_mixer():
	g.interface.toggle_mixer()



func slider_sound_volume(value):
	g.set_sound_volume(value)


func slider_music_volume(value):
	g.music.set_volume(value)






