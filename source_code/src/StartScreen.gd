extends Control

var age :int = -1
var player_name : String = "Unnamed"

var regex = RegEx.new()
var oldtext = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	regex.compile("^[0-9]*$")


func _on_StartButton_pressed():
	Autoload.player_name = player_name
	Autoload.age = int(oldtext)
	Autoload.restart()
	get_tree().change_scene("res://src/Level.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_Name_text_changed(new_text):
	player_name = new_text


func _on_Age_text_changed(new_text):
	if regex.search(new_text):
		$Age.text = new_text   
		oldtext = $Age.text
	else:
		$Age.text = oldtext
	$Age.set_cursor_position($Age.text.length())
