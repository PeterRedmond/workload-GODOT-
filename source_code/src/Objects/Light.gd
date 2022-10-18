extends Node2D

signal active_light

export(float) var min_time_to_light
export(float) var max_time_to_light
var time_to_light
var is_light = false
var light_color : String
var base_color = Color.dimgray
var available_colors

var start_time = 0
var end_time = 0
var button_colors

func _ready():
	randomize()
	time_to_light = get_time_to_light()
	$Timer.start(time_to_light)
	modulate = base_color

func _on_Timer_timeout():
	start_time = OS.get_ticks_msec()
	is_light = true
	emit_signal("active_light", self, light_color)

func get_time_to_light():
	return rand_range(min_time_to_light, max_time_to_light)

func light_off():
	end_time = OS.get_ticks_msec()
	is_light = false
	Autoload.lights_on += (end_time - start_time)
	time_to_light = get_time_to_light()
	$Timer.start(time_to_light)
	modulate = base_color
	set_color()

func set_color():
	available_colors = button_colors.keys()
	light_color = available_colors[randi() % available_colors.size()]
