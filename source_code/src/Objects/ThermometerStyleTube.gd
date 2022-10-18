extends Control

export(float, 0, 100) var fill_per_unit_time
export(float) var unit_time
export(float, 0, 100) var min_value
export(float, 0, 100) var max_value
export(bool) var tap_button_pressed
var overflow_time = 0
var start_time = 0
var end_time = 0
var timer_started = false

func _ready():
	$Timer.start(unit_time)
	if min_value > max_value:
		var temp = min_value
		min_value = max_value
		max_value = temp
	var min_y = $Button.rect_size.y + 10 + ( min_value * $ThermometerStyleTube.rect_size.x / 100 )
	var max_y = $Button.rect_size.y + 10 + ( max_value * $ThermometerStyleTube.rect_size.x / 100 )
	var width_x = $ThermometerStyleTube.rect_size.y
	
	$MinLine2D.points = [Vector2(0, min_y), Vector2(width_x, min_y)]
	$MaxLine2D.points = [Vector2(0, max_y), Vector2(width_x, max_y)]


func _on_Timer_timeout():
	if tap_button_pressed:
		$ThermometerStyleTube.value += fill_per_unit_time
		if $ThermometerStyleTube.value > max_value:
			$ThermometerStyleTube/AnimationPlayer.play("Blink")
			if not timer_started:
				start_timer()
		else:
			if timer_started:
				stop_timer()
				$ThermometerStyleTube/AnimationPlayer.play("Idle")
	else:
		$ThermometerStyleTube.value -= fill_per_unit_time
		if $ThermometerStyleTube.value < min_value:
			$ThermometerStyleTube/AnimationPlayer.play("Blink")
			if not timer_started:
				start_timer()
		else:
			if timer_started:
				$ThermometerStyleTube/AnimationPlayer.play("Idle")
				stop_timer()

func _on_Button_toggled(button_pressed):
	tap_button_pressed = button_pressed



func start_timer():
	start_time = OS.get_ticks_msec()
	timer_started = true

func stop_timer():
	end_time = OS.get_ticks_msec()
	if tap_button_pressed:
		Autoload.water_underflow += (end_time - start_time)
	else:
		Autoload.water_overflow += (end_time - start_time)
	timer_started = false
