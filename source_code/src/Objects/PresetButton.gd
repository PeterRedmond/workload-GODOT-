
extends Button



func _on_PresetButton_pressed():
	get_tree().change_scene("res://src/World" + str(name[-1]) + ".tscn")
	Autoload.level_number = int(name[-1])
