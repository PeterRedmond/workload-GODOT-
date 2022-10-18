extends Button

signal color_button_pressed

export var button_color = "Red"

func _ready():
	pass
	
func set_color(button_colors):
	var new_stylebox = get("custom_styles/normal").duplicate()
	new_stylebox.bg_color = button_colors[button_color]
	set("custom_styles/normal", new_stylebox)
	set("custom_styles/hover", new_stylebox)


func _on_Button1_pressed():
	emit_signal("color_button_pressed", button_color)
