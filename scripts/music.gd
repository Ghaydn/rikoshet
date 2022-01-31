extends AudioStreamPlayer

onready var stopper = $stopper

var enabled: bool = true
var current_category: String = "none" # calm or fast
var current_index: int = 1


var calm_list = [
	r.pads_music,
	r.sine_slow_music,
]

var fast_list = [
	r.drummed_music,
	r.sine_fast_music,
]

func _ready():
	g.music = self

func get_proper_music() -> String:
	if g.pole.count_balls() == 0:
		return "calm"
	else:
		return "fast"
	#return "none"

func run_music(category: String):
	if current_category == category:
		current_index = (current_index + 1) % calm_list.size()
	else:
		current_index = randi() % calm_list.size()
	match category:
		"calm":
			self.stream = calm_list[current_index]
			self.play()
			self.volume_db = 0
		"fast":
			self.stream = fast_list[current_index]
			self.play()
			self.volume_db = 0
	current_category = category

func stop_music():
	stopper.interpolate_property(self, "volume_db", 0, -80, 1.53)
	stopper.start()

func toggle_mute():
	enabled = not enabled
	if not enabled: stop_music()

func set_enabled(value: bool):
	if value:
		enabled = true
	else:
		stop_music()
		enabled = false
	g.interface.mute_music_button.pressed = not value

func set_volume(value: float):
	var new_value = linear2db(value)
	AudioServer.set_bus_volume_db(1, new_value)
	g.interface.music_vol.value = value


func music_timer():
	if not enabled: return
	if self.playing:
		if get_proper_music() != current_category:
			stop_music()
	else:
		run_music(get_proper_music())


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func music_stopped(object, key):
	self.stop()
