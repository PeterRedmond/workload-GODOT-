extends Node2D

export(int) var level_time
var total_score = 0
var active_lights = []

var regex = RegEx.new()
var oldtext = ""

var number_ans = -1
var color_ans = "no_ans"
var is_number_question = false
var is_color_question = false

export(float) var min_time_to_color_question
export(float) var max_time_to_color_question
var time_to_color_question
var color_question_start_time = 0
var color_question_end_time = 0
var color_stylebox

export(float) var min_time_to_number_question
export(float) var max_time_to_number_question
var time_to_number_question
var number_question_start_time = 0
var number_question_end_time = 0
var number_stylebox

export var color_question_names_list = ["red", "green", "blue", "yellow", "white",]
export var color_question_colors_list = {
	"Red" : Color.red,
	"Green" : Color.green,
	"Blue" : Color.blue,
	"Yellow" : Color.yellow,
	"White" : Color.white,
}

export var button_colors = {
	"Red" : Color.red,
	"Green" : Color.green,
}

var score_file = "data.txt"
var total_keypress = 0
var total_mouse_clicks = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Text.text = ""
	$Number.text = ""
	regex.compile("^[0-9]*$")
	$LevelTimer.start(level_time)
	time_to_number_question = get_time_to_number_question()
	$NumberTimer.start(time_to_number_question)
	time_to_color_question = get_time_to_color_question()
	$ColorTimer.start(time_to_color_question)
	for light in $Lights.get_children():
		light.button_colors = button_colors
		light.set_color()
		light.connect("active_light", self, "_on_Light_Active")
	for color_button in $Buttons.get_children():
		color_button.set_color(button_colors)
		color_button.connect("color_button_pressed", self, "_on_ColorButton_pressed")
	$TextLineEdit.grab_focus()
	
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			total_mouse_clicks += 1
	if event is InputEventKey:
		if event.is_pressed():
			total_keypress += 1

func _on_Light_Active(light_object, light_color):
	light_object.modulate = button_colors[light_color]
	light_object.modulate *= 1.5
	light_object.modulate.a = 1
	active_lights.append([light_object, light_color])



func _on_ColorButton_pressed(color):
	for light in active_lights:
		if light[1] == color:
			light[0].light_off()
			active_lights.erase(light)
		
func _on_TextLineEdit_text_changed(new_text):
	if new_text != "" and regex.search(new_text[-1]):
		$TextLineEdit.text = oldtext
		check_number_ans(new_text[-1])
	else:
		$TextLineEdit.text = new_text   
		oldtext = $TextLineEdit.text
		check_color_ans(new_text)
	$TextLineEdit.set_cursor_position($TextLineEdit.text.length())


func _on_StartButton_pressed():
	get_tree().paused = false
	Autoload.restart()
	get_tree().reload_current_scene()


func _on_LevelTimer_timeout():
	set_score()
	$LevelEnd.show()
	get_tree().paused = true


func _on_QuitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://src/StartScreen.tscn")

func set_score():
	$MovingBall.time_up()
	for tube in $Tubes.get_children():
		tube.time_up()
	for light in $Lights.get_children():
		light.light_off()
		total_score = Autoload.water_overflow + Autoload.water_underflow + Autoload.moving_ball_stopped + Autoload.lights_on + Autoload.word_on_screen + Autoload.number_on_screen
	$LevelEnd/ScoreLabel.text =  "Score : " + str(total_score) + " ms"
	$LevelEnd/WaterOverFlow.text = "Water Overflow : " + str(Autoload.water_overflow)
	$LevelEnd/WaterUnderFlow.text = "Water Underflow : " + str(Autoload.water_underflow)
	$LevelEnd/BallStopped.text = "Ball Stopped : " + str(Autoload.moving_ball_stopped)
	$LevelEnd/LightsOn.text = "Lights On : " + str(Autoload.lights_on)
	$LevelEnd/WordQuestion.text = "Word Question : " + str(Autoload.word_on_screen)
	$LevelEnd/NumberQuestion.text = "Number Question : " + str(Autoload.number_on_screen)
	save_score()

func get_time_to_number_question():
	return rand_range(min_time_to_number_question, max_time_to_number_question)

func get_time_to_color_question():
	return rand_range(min_time_to_color_question, max_time_to_color_question)

func check_number_ans(number_entered):
	if int(number_entered) == number_ans:
		number_question_end_time = OS.get_ticks_msec()
		Autoload.number_on_screen += (number_question_end_time - number_question_start_time)
		is_color_question = false
		time_to_number_question = get_time_to_number_question()
		$Number.text = ""
		$NumberTimer.start(time_to_number_question)
	
func check_color_ans(color_name_entered):
	if color_name_entered.to_lower() == color_ans.to_lower():
		color_question_end_time = OS.get_ticks_msec()
		Autoload.word_on_screen += (color_question_end_time - color_question_start_time)
		is_color_question = false
		time_to_color_question = get_time_to_color_question()
		$TextLineEdit.clear()
		$Text.text = ""
		$ColorTimer.start(time_to_color_question)

func make_number_question():
	number_ans = randi() % 9 + 1
	var first_no = 0
	var second_no = 0
	if randi() % 2 == 0:
		first_no = number_ans + randi() % 9 + 1
		second_no = first_no - number_ans
		$Number.text = str(first_no) + " - " + str(second_no)
	else:
		first_no = randi() % number_ans + 1
		second_no = number_ans - first_no
		$Number.text = str(first_no) + " + " + str(second_no)
	is_number_question = true
	number_question_start_time = OS.get_ticks_msec()

func make_color_question():
	color_ans = color_question_colors_list.keys()[randi() % color_question_colors_list.size()]
	$Text.set("custom_colors/font_color", color_question_colors_list[color_ans])
	var text_displayed = color_question_names_list[randi() % color_question_colors_list.size()]
	$Text.text = text_displayed
	is_color_question = true
	color_question_start_time = OS.get_ticks_msec()

func _on_NumberTimer_timeout():
	make_number_question()


func _on_ColorTimer_timeout():
	make_color_question()


func save_score():
	var file = File.new()
	if file.file_exists(score_file):
		file.open(score_file, File.READ_WRITE)
	else:
		file.open(score_file, File.WRITE)
	file.seek_end()
	var save_text = "Name : " + Autoload.player_name 
	save_text += " Age :" + str(Autoload.age) 
	save_text += " Score : " + str(total_score) 
	save_text += " Level Time : " + str(level_time) 
	save_text += " Keys Pressed : " + str(total_keypress) 
	save_text += " Mouse Clicks : " + str(total_mouse_clicks)
	save_text += " Level Number : " + str(Autoload.level_number) 
	file.store_line(save_text)
	file.close()
